// Garden Calendar — Backfill Plant Photos Edge Function
// Admin-triggered: cerca su Pexels una foto per ogni pianta del catalogo
// che non ne ha ancora una, e aggiorna plant_knowledge.image_url.

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
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
        JSON.stringify({ error: "Solo l'admin può eseguire il backfill" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    const pexelsKey = Deno.env.get("PEXELS_API_KEY")
    if (!pexelsKey) {
      return new Response(
        JSON.stringify({ error: "PEXELS_API_KEY non configurata" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    const { data: rows, error: fetchError } = await supabaseAdmin
      .from("plant_knowledge")
      .select("id, specie_nome, specie_nome_scientifico")
      .is("image_url", null)

    if (fetchError) {
      return new Response(
        JSON.stringify({ error: "Errore lettura catalogo", details: fetchError.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    let updated = 0
    let notFound = 0
    const failed: string[] = []

    for (const row of rows ?? []) {
      const query = row.specie_nome_scientifico || row.specie_nome
      try {
        const res = await fetch(
          `https://api.pexels.com/v1/search?query=${encodeURIComponent(`${query} plant`)}&per_page=1&orientation=square`,
          { headers: { Authorization: pexelsKey } }
        )
        if (!res.ok) { failed.push(row.specie_nome); continue }
        const data = await res.json()
        const imageUrl = data.photos?.[0]?.src?.medium
        if (!imageUrl) { notFound++; continue }

        const { error: updateError } = await supabaseAdmin
          .from("plant_knowledge")
          .update({ image_url: imageUrl })
          .eq("id", row.id)
        if (updateError) { failed.push(row.specie_nome); continue }
        updated++
      } catch {
        failed.push(row.specie_nome)
      }
      // Pexels free tier: 200 richieste/ora — piccola pausa per sicurezza
      await new Promise((r) => setTimeout(r, 250))
    }

    return new Response(
      JSON.stringify({ total: rows?.length ?? 0, updated, notFound, failed }),
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
