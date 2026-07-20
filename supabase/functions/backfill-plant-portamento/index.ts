// Garden Calendar — Backfill Plant Portamento Edge Function
// Admin-triggered: chiede a DeepSeek (via OpenRouter) il portamento di ogni pianta
// del catalogo che non ne ha ancora uno, e aggiorna plant_knowledge.portamento.

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

const VALID_PORTAMENTI = ["tappezzante", "ricadente", "rampicante", "eretto", "cespuglioso"]

const SYSTEM_PROMPT = `Sei un esperto agronomo. Dato il nome di una pianta (ed
eventuale nome scientifico e descrizione), rispondi con UNA SOLA PAROLA tra:
tappezzante, ricadente, rampicante, eretto, cespuglioso — quella che meglio
descrive il portamento della pianta. Nessun altro testo, nessuna punteggiatura.`

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

    const openRouterKey = Deno.env.get("OPENROUTER_API_KEY")
    if (!openRouterKey) {
      return new Response(
        JSON.stringify({ error: "OPENROUTER_API_KEY non configurata" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    const { data, error: fetchError } = await supabaseAdmin
      .from("plant_knowledge")
      .select("id, specie_nome, specie_nome_scientifico, descrizione")
      .is("portamento", null)
    if (fetchError) {
      return new Response(
        JSON.stringify({ error: "Errore lettura catalogo", details: fetchError.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    const rows: { id: string; specie_nome: string; specie_nome_scientifico: string | null; descrizione: string | null }[] = data ?? []

    let updated = 0
    const failed: string[] = []

    for (const row of rows) {
      try {
        const userContent = `Pianta: ${row.specie_nome}` +
          (row.specie_nome_scientifico ? `\nNome scientifico: ${row.specie_nome_scientifico}` : "") +
          (row.descrizione ? `\nDescrizione: ${row.descrizione}` : "")

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
              { role: "user", content: userContent },
            ],
          }),
        })

        if (!llmResponse.ok) { failed.push(row.specie_nome); continue }
        const llmData = await llmResponse.json()
        const raw = (llmData.choices?.[0]?.message?.content ?? "").trim().toLowerCase()
        const portamento = VALID_PORTAMENTI.find((p) => raw.includes(p))
        if (!portamento) { failed.push(row.specie_nome); continue }

        const { error: updateError } = await supabaseAdmin
          .from("plant_knowledge")
          .update({ portamento })
          .eq("id", row.id)
        if (updateError) { failed.push(row.specie_nome); continue }
        updated++
      } catch {
        failed.push(row.specie_nome)
      }
      // Rate limit OpenRouter: piccola pausa tra le richieste
      await new Promise((r) => setTimeout(r, 250))
    }

    return new Response(
      JSON.stringify({ total: rows.length, updated, failed }),
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
