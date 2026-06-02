// Garden Calendar — Forward Scheduling Edge Function
// Triggered when a user plants/sows a new plant.
// Generates all future activities (irrigation, fertilizing, harvesting, etc.)
// based on the plant's template activities.

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

interface TemplateActivity {
  nome: string
  offset_days: number
  recurrence_days: number | null
  color: string
}

interface ScheduleRequest {
  pianta_id: string
  data_semina: string        // ISO date (YYYY-MM-DD)
  growth_days: number
  activities: TemplateActivity[]
}

interface Attivita {
  pianta_id: string
  nome: string
  data: string
  done: boolean
  rain_adjusted: boolean
  rain_rescheduled: boolean
  user_event: boolean
  source_action: string
  color: string
  recurrence_days: number | null
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    // Validate auth
    const authHeader = req.headers.get("Authorization")
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Mancante header Authorization" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Create Supabase client with service role key (bypass RLS for inserts)
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } }
    )

    // Verify the JWT and get user
    const token = authHeader.replace("Bearer ", "")
    const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(token)
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: "Token non valido" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Parse request body
    const body: ScheduleRequest = await req.json()
    const { pianta_id, data_semina, growth_days, activities } = body

    // Validation
    if (!pianta_id || !data_semina || !growth_days || !activities?.length) {
      return new Response(
        JSON.stringify({ error: "Parametri mancanti: pianta_id, data_semina, growth_days, activities" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Verify the plant belongs to this user
    const { data: pianta, error: piantaError } = await supabaseAdmin
      .from("piante_coltivate")
      .select("id, orto_id")
      .eq("id", pianta_id)
      .single()

    if (piantaError || !pianta) {
      return new Response(
        JSON.stringify({ error: "Pianta non trovata" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Verify the garden belongs to this user
    const { data: orto, error: ortoError } = await supabaseAdmin
      .from("orti")
      .select("user_id")
      .eq("id", pianta.orto_id)
      .single()

    if (ortoError || !orto || orto.user_id !== user.id) {
      return new Response(
        JSON.stringify({ error: "Accesso negato: questa pianta non ti appartiene" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // --- SCHEDULING LOGIC ---
    // Replicating the Python scheduler logic:
    // For each template activity, calculate dates within the plant lifespan
    const seminaDate = new Date(data_semina)
    const plantLifespan = Math.max(growth_days, 30)
    const scheduledActivities: Attivita[] = []

    for (const activity of activities) {
      const baseDate = addDays(seminaDate, activity.offset_days)

      if (activity.recurrence_days && activity.recurrence_days > 0) {
        // Recurring activity — generate all occurrences within lifespan
        let occurrence = baseDate
        const endDate = addDays(seminaDate, plantLifespan)
        while (occurrence <= endDate) {
          const color = resolveColor(activity.nome, activity.color)
          scheduledActivities.push({
            pianta_id,
            nome: activity.nome,
            data: formatDate(occurrence),
            done: false,
            rain_adjusted: false,
            rain_rescheduled: false,
            user_event: false,
            source_action: "semina",
            color,
            recurrence_days: activity.recurrence_days,
          })
          occurrence = addDays(occurrence, activity.recurrence_days)
        }
      } else {
        // One-shot activity
        if (activity.offset_days > plantLifespan) {
          continue // Skip activities past the plant's lifespan
        }
        const color = resolveColor(activity.nome, activity.color)
        scheduledActivities.push({
          pianta_id,
          nome: activity.nome,
          data: formatDate(baseDate),
          done: false,
          rain_adjusted: false,
          rain_rescheduled: false,
          user_event: false,
          source_action: "semina",
          color,
          recurrence_days: null,
        })
      }
    }

    // Insert all scheduled activities
    if (scheduledActivities.length === 0) {
      return new Response(
        JSON.stringify({ message: "Nessuna attività da schedulare", count: 0 }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    const { data: inserted, error: insertError } = await supabaseAdmin
      .from("attivita")
      .insert(scheduledActivities)
      .select("id, nome, data, color")

    if (insertError) {
      console.error("Insert error:", insertError)
      return new Response(
        JSON.stringify({ error: "Errore durante l'inserimento delle attività", details: insertError.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    return new Response(
      JSON.stringify({
        message: `Schedulazione completata: ${scheduledActivities.length} attività generate`,
        count: scheduledActivities.length,
        activities: inserted,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )
  } catch (err) {
    console.error("Unexpected error:", err)
    return new Response(
      JSON.stringify({ error: "Errore interno del server", details: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )
  }
})

// --- Helper functions ---

function addDays(date: Date, days: number): Date {
  const result = new Date(date)
  result.setDate(result.getDate() + days)
  return result
}

function formatDate(date: Date): string {
  return date.toISOString().split("T")[0]
}

function resolveColor(activityName: string, defaultColor: string): string {
  const name = activityName.toLowerCase()
  if (name.includes("raccolt")) return "orange"
  if (name.includes("irrigaz") || name.includes("acqua")) return "blue"
  if (name.includes("concim") || name.includes("fertil") || name.includes("trattam") ||
      name.includes("fungic") || name.includes("insett") || name.includes("antiparassit")) return "red"
  if (name.includes("potatur") || name.includes("sarchiat") || name.includes("innest")) return "gray"
  if (name.includes("semina") || name.includes("trapiant")) return "green"
  return defaultColor || "purple"
}
