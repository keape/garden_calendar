# Rifiuto App Store 5.1.2(i) — Privacy Tracking ATT

**Data:** 2026-06-12
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** debug
**Status:** in-progress
**Tags:** appstoreconnect, privacy, ATT, rejection, supabase

## Cosa abbiamo fatto

- Ricevuto rifiuto Apple Guideline 5.1.2(i): app dichiara raccolta User ID per tracking ma non usa ATTrackingTransparency framework
- Confermato via grep: zero codice ATT, zero SDK analytics/tracking nell'app
- User ID usato solo per autenticazione Supabase, non per tracking cross-app
- Screenshot ASC mostra User ID purpose = "Funzionalità delle app" ✓ (già corretto)
- Identificato causa reale: toggle "Usato per tracciarti" (Used to Track You) a livello data type, separato dal purpose

## Decisioni prese

- Fix corretto: Option 1 Apple → aggiornare privacy info ASC, non implementare ATT
- Nessun codice da toccare: il problema è solo nella configurazione ASC

## Prossimi passi

- In ASC App Privacy → trovare sezione "Dati usati per tracciarti" → verificare se User ID o altri tipi appaiono lì
- Se sì: modificare User ID → step "Usato per tracciare l'utente?" → impostare NO
- Re-submit senza nuovo build

## Contesto tecnico rilevante

- Submission ID rifiutata: `9e7c42af-c261-4c5f-9b66-c42bca97a334`
- Build 2 (già uploadato con Delivery UUID `de37145b-8b41-4ca7-bf55-909dfc317bfb`)
- Nessun ATT framework nel codice (grep confermato su sorgenti principali)
