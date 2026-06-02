// Garden Calendar — LLM Plant Care Extraction Edge Function
// Triggered from the admin dashboard when a wiki note is saved.
// Calls DeepSeek via OpenRouter to extract structured care data
// from the markdown wiki note content.

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

interface ExtractRequest {
  wiki_note_id: string
}

interface LLMResponse {
  growth_days: number
  activities: Array<{
    name: string
    offset_days: number
    recurrence_days: number | null
  }>
  missing_info?: boolean
}

const SYSTEM_PROMPT = `Sei un esperto agronomo specializzato in orticoltura annuale e
biennale. Dati degli estratti da note wiki su una pianta,
restituisci un JSON con questa struttura esatta:
{
  "growth_days": <intero: giorni dalla semina/trapianto alla raccolta>,
  "activities": [
    {
      "name": "<nome attività in italiano>",
      "offset_days": <intero: giorni dalla data di semina/trapianto>,
      "recurrence_days": <intero o null: se ricorrente, ogni quanti giorni>
    }
  ],
  "missing_info": <boolean: true se le info sono insufficienti>
}

Regole:
- growth_days: per ORTAGGI ANNUALI (lattuga, pomodori, peperoni, cetrioli, zucchine,
  melanzane, basilico, valeriana/songino, rucola, spinaci, bietola, carote, ravanelli,
  fagioli, piselli, cipolle, aglio, fragole, ecc.) NON superare mai 180 giorni.
  I ravanelli maturano in 25-30gg, le insalate da taglio in 50-70gg,
  pomodori/peperoni in 70-120gg. 730gg è un valore IRRAGIONEVOLE per un ortaggio —
  solo piante perenni o arboree possono arrivare a quelle durate.
- "raccolta" DEVE SEMPRE essere inclusa tra le attività, con offset_days = growth_days.
  È l'attività più importante per il calendario. Non ometterla mai.
- NON includere "semina" o "trapianto" tra le attività — sono azioni registrate manualmente.
- activities deve includere TUTTE le altre cure: concimazioni, irrigazioni ordinarie,
  irrigazioni straordinarie, controllo parassiti, trattamenti, potature, ecc.
- offset_days = numero di giorni dalla data di semina/trapianto a quando l'attività
  deve avvenire per la prima volta.
- Per attività stagionali (es. "potatura autunnale", "pacciamatura invernale"):
  calcola offset_days come la differenza in giorni tra una data di semina
  tipica per quella specie e la data in cui quella stagione inizia.
- Per cura ordinaria continua (irrigazione, sarchiatura, concimazione basale): offset_days=0
  se non indicato altrimenti — queste cure iniziano subito dopo il trapianto.
- Per attività che richiedono uno stadio di crescita (cimatura a prima fioritura, raccolta
  foglie, ecc.): stima i giorni usando la tua conoscenza agronomica della specie.
- Se le informazioni sono insufficienti per determinare growth_days, usa 90 e imposta
  "missing_info": true nel JSON.
- Restituisci SOLO il JSON, nessun testo aggiuntivo.`

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    // Validate auth — only admin can trigger extraction
    const authHeader = req.headers.get("Authorization")
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Mancante header Authorization" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } }
    )

    const token = authHeader.replace("Bearer ", "")
    const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(token)
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: "Token non valido" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Check admin role from JWT claims
    // Decode JWT payload to check is_admin (userMetadata not always populated in edge runtime)
    const tokenParts = token.split('.')
    let isAdmin = false
    if (tokenParts.length === 3) {
      try {
        const payload = JSON.parse(atob(tokenParts[1]))
        isAdmin = payload?.user_metadata?.is_admin === true || payload?.user_metadata?.is_admin === 'true'
      } catch { /* ignore decode errors */ }
    }
    
    if (!isAdmin) {
      return new Response(
        JSON.stringify({ error: "Solo l'admin può estrarre dati dalle wiki notes" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Parse request
    const body: ExtractRequest = await req.json()
    const { wiki_note_id } = body

    if (!wiki_note_id) {
      return new Response(
        JSON.stringify({ error: "Parametro mancante: wiki_note_id" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Fetch the wiki note
    const { data: wikiNote, error: wikiError } = await supabaseAdmin
      .from("wiki_notes")
      .select("*")
      .eq("id", wiki_note_id)
      .single()

    if (wikiError || !wikiNote) {
      return new Response(
        JSON.stringify({ error: "Wiki note non trovata" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Call OpenRouter API (DeepSeek)
    const openRouterKey = Deno.env.get("OPENROUTER_API_KEY")
    if (!openRouterKey) {
      return new Response(
        JSON.stringify({ error: "OPENROUTER_API_KEY non configurata" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    const llmResponse = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${openRouterKey}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "https://garden-calendar.app",
      },
      body: JSON.stringify({
        model: "deepseek/deepseek-v4-flash",
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          { role: "user", content: `Pianta: ${wikiNote.title}\n\nNote wiki:\n${wikiNote.markdown_content}` },
        ],
        response_format: { type: "json_object" },
      }),
    })

    if (!llmResponse.ok) {
      const errorText = await llmResponse.text()
      console.error("OpenRouter API error:", errorText)
      return new Response(
        JSON.stringify({ error: "Errore API OpenRouter", details: errorText }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    const llmData = await llmResponse.json()
    const rawContent = llmData.choices?.[0]?.message?.content
    if (!rawContent) {
      return new Response(
        JSON.stringify({ error: "Risposta LLM vuota" }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Parse LLM response
    let llmResult: LLMResponse
    try {
      llmResult = JSON.parse(rawContent)
    } catch {
      return new Response(
        JSON.stringify({ error: "Risposta LLM non valida", raw: rawContent }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Map to the activity format with colors
    const slug = wikiNote.slug || wikiNote.title.toLowerCase().replace(/\s+/g, "-").replace(/[^a-z0-9-]/g, "")
    const activitiesWithColors = llmResult.activities.map((a) => ({
      nome: a.name,
      offset_days: a.offset_days,
      recurrence_days: a.recurrence_days,
      color: resolveColor(a.name),
    }))

    // Upsert into plant_knowledge
    const { data: knowledge, error: upsertError } = await supabaseAdmin
      .from("plant_knowledge")
      .upsert({
        slug,
        specie_nome: wikiNote.title,
        growth_days: llmResult.growth_days,
        attivita_suggerite: JSON.stringify(activitiesWithColors),
      }, { onConflict: "slug", ignoreDuplicates: false })
      .select()
      .single()

    if (upsertError) {
      console.error("Upsert error:", upsertError)
      return new Response(
        JSON.stringify({ error: "Errore salvataggio knowledge", details: upsertError.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Mark wiki note as processed
    await supabaseAdmin
      .from("wiki_notes")
      .update({ processed: true })
      .eq("id", wiki_note_id)

    return new Response(
      JSON.stringify({
        message: `Knowledge estratta con successo per "${wikiNote.title}"`,
        slug,
        growth_days: llmResult.growth_days,
        activities_count: llmResult.activities.length,
        missing_info: llmResult.missing_info || false,
        knowledge_id: knowledge.id,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )
  } catch (err) {
    console.error("Unexpected error:", err)
    return new Response(
      JSON.stringify({ error: "Errore interno", details: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )
  }
})

function resolveColor(activityName: string): string {
  const name = activityName.toLowerCase()
  if (name.includes("raccolt")) return "orange"
  if (name.includes("irrigaz") || name.includes("acqua")) return "blue"
  if (name.includes("concim") || name.includes("fertil") || name.includes("trattam") ||
      name.includes("fungic") || name.includes("insett") || name.includes("antiparassit")) return "red"
  if (name.includes("potatur") || name.includes("sarchiat") || name.includes("innest")) return "gray"
  if (name.includes("semina") || name.includes("trapiant")) return "green"
  return "purple"
}
