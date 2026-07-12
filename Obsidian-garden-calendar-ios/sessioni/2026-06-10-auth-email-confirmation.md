# Auth — Disabilitazione email confirmation e auto-login

**Data:** 2026-06-10
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** config
**Status:** complete
**Tags:** supabase, swift, auth, ios

## Cosa abbiamo fatto

- Diagnosticato problema OTP email non arrivante → email confirmation non necessaria per app hobbistica
- Disabilitato "Confirm email" nel dashboard Supabase (project: `kusprtmfxrsnjycyzlgs`)
- Fixato `AuthManager.signUp` per catturare `response.session` → `isAuthenticated = true` immediato
- Aggiornato messaggio success in `SignUpView` (rimosso "controlla email")
- Committato e pushato anche fix pregressi non committiati: `SettingsView` auth wiring, deep link handler, URL scheme `garden-calendar://`
- Eliminata skill duplicata `claude-obsidian:save`

## Decisioni prese

- Email confirmation disabilitata: app personale/hobbistica, nessun requisito legale o di sicurezza che la richieda
- OTP non implementato: overhead non giustificato per questo tipo di app

## Prossimi passi

- Nessun follow-up aperto.

## Contesto tecnico rilevante

File toccati:
- `GardenCalendar/Services/AuthManager.swift` — signUp cattura session
- `GardenCalendar/Views/Auth/SignUpView.swift` — alert message
- `GardenCalendar/Views/Settings/SettingsView.swift` — email da AuthManager, signOut attivo
- `GardenCalendar/GardenCalendarApp.swift` — onOpenURL deep link
- `GardenCalendar/Info.plist` — URL scheme `garden-calendar://`
