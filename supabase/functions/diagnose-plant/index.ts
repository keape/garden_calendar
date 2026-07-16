// Garden Calendar — LLM Plant Diagnosis Edge Function
// Triggered from the app's "Diagnosi" tab. Sends a user's plant photo,
// together with the plant's full activity history, to a vision-capable
// LLM (via OpenRouter) which returns a text diagnosis.

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

interface DiagnoseRequest {
  pianta_id: string
  image_base64: string
}

const MODEL = "google/gemini-2.5-flash"

const SYSTEM_PROMPT = `Sei un agronomo fitopatologo esperto in orticoltura. Ricevi la foto
di una pianta coltivata da un utente amatoriale, insieme ai dati della pianta e allo
storico completo delle attività di cura registrate (sia quelle già svolte sia quelle
programmate/non ancora fatte).

Il tuo compito:
1. Osserva la foto e individua eventuali problemi visibili: malattie fungine, parassiti,
   carenze nutritive, stress idrico (eccesso o carenza), scottature, marciumi, ecc.
2. Incrocia quanto osservi con lo storico delle attività: es. se la pianta mostra clorosi
   e non risultano concimazioni fatte, sospetta carenza nutritiva; se mostra marciume radicale
   e risultano irrigazioni recenti frequenti, sospetta eccesso idrico; se un trattamento
   antiparassitario era programmato ma non risulta fatto, segnalalo come causa probabile.
3. Tieni conto dell'età della pianta (giorni dalla semina) e del ciclo di crescita previsto.

Rispondi in italiano, in testo semplice (NON JSON), con questa struttura:
- Diagnosi: cosa osservi nella foto.
- Cause probabili: correlate allo storico attività quando pertinente.
- Azioni consigliate: cosa fare ora, in modo concreto e specifico per questa pianta.

Se la foto non mostra problemi evidenti, dillo chiaramente e conferma che la pianta appare
in salute, eventualmente con consigli di mantenimento basati sullo storico.`

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

    const body: DiagnoseRequest = await req.json()
    const { pianta_id, image_base64 } = body

    if (!pianta_id || !image_base64) {
      return new Response(
        JSON.stringify({ error: "Parametri mancanti: pianta_id, image_base64" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Fetch the plant and verify it belongs to the requesting user (via orto owner)
    const { data: pianta, error: piantaError } = await supabaseAdmin
      .from("piante_coltivate")
      .select("*, orti!inner(user_id)")
      .eq("id", pianta_id)
      .single()

    if (piantaError || !pianta) {
      return new Response(
        JSON.stringify({ error: "Pianta non trovata" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    if (pianta.orti?.user_id !== user.id) {
      return new Response(
        JSON.stringify({ error: "Non autorizzato su questa pianta" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // Fetch full activity history for the plant (done and not done)
    const { data: attivita, error: attivitaError } = await supabaseAdmin
      .from("attivita")
      .select("nome, data, done, note")
      .eq("pianta_id", pianta_id)
      .order("data")

    if (attivitaError) {
      console.error("Errore fetch attivita:", attivitaError)
      return new Response(
        JSON.stringify({ error: "Errore recupero storico attività", details: attivitaError.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    const dataSemina = new Date(pianta.data_semina)
    const giorniTrascorsi = Math.floor((Date.now() - dataSemina.getTime()) / (1000 * 60 * 60 * 24))

    const storicoText = (attivita ?? []).length === 0
      ? "(nessuna attività registrata)"
      : attivita.map((a) => {
          const stato = a.done ? "fatta" : "da fare"
          const nota = a.note ? ` — nota: ${a.note}` : ""
          return `${a.data} — ${a.nome} — ${stato}${nota}`
        }).join("\n")

    const nomePianta = pianta.nome_personalizzato || "pianta"
    const userText = `Pianta: ${nomePianta}. Semina: ${pianta.data_semina} (${giorniTrascorsi} giorni fa). ` +
      `Ciclo previsto: ${pianta.growth_days} giorni. Note: ${pianta.note || "nessuna"}.\n` +
      `Storico attività (data — nome — stato — note):\n${storicoText}\n\n` +
      `Analizza la foto e diagnostica i problemi tenendo conto di questo storico.`

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
        model: MODEL,
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          {
            role: "user",
            content: [
              { type: "text", text: userText },
              { type: "image_url", image_url: { url: image_base64 } },
            ],
          },
        ],
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
    const diagnosis = llmData.choices?.[0]?.message?.content
    if (!diagnosis) {
      return new Response(
        JSON.stringify({ error: "Risposta LLM vuota" }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    return new Response(
      JSON.stringify({ diagnosis }),
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
