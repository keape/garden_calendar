# Privacy Policy e questionario App Store Connect

**Data:** 2026-06-05
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** config
**Status:** complete
**Tags:** app-store, privacy, supabase, open-meteo, gdpr

## Cosa abbiamo fatto

- Analizzato il codice dell'app (AuthManager, LocationHelper, SupabaseRepository, RainAdjuster) per identificare tutti i dati raccolti
- Scritto la Privacy Policy in inglese seguendo lo stile di Budget365, con contatto keape@me.com (Alessandro Capobianco)
- Compilato il questionario App Store Connect sezione per sezione:
  - Risposto "Sì" alla raccolta dati (Supabase raccoglie dati persistentemente)
  - Selezionati: indirizzo email, posizione approssimativa, ID utente, altri contenuti utente
  - Email: uso = Funzionalità app; collegata a identità = Sì; tracking = No
  - Posizione approssimativa: collegata a identità = Sì (salvata in `orti.user_id`); tracking = No
  - ID utente: uso = Funzionalità app; collegato a identità = Sì

## Decisioni prese

- Posizione classificata come **approssimativa** (non precisa): `kCLLocationAccuracyKilometer` → risoluzione < 3 decimali
- Open-Meteo **non** dichiarato come raccolta dati: riceve solo coordinate in tempo reale senza retention → fuori dalla definizione Apple di "raccolta"
- Nessun tracking, analytics, pubblicità → tutte le domande di tracking = No

## Prossimi passi

- Completare la sezione "Altri contenuti utente" nel questionario (dati orto, piante, attività, note)
- Pubblicare la Privacy Policy su una pagina Notion o URL pubblico da linkare in App Store Connect
