# App Store rejection fix — ATT, deep link email, demo account

**Data:** 2026-06-10
**Progetto:** garden-calendar-ios
**Durata:** media
**Tipo:** bug
**Status:** complete
**Tags:** appstore, supabase, deep-link, auth, xcode

## Cosa abbiamo fatto

- Analizzato rejection App Store Connect (submission f3dd1774): 3 guideline violate
- **Guideline 5.1.2(i) ATT**: utente ha rimosso flag "tracking" dalle privacy labels in App Store Connect (no codice)
- **Guideline 2.1(a) email verification URL invalido**: aggiunto URL scheme `garden-calendar` in Info.plist, implementato `handleDeepLink` in AuthManager usando `client.auth.handle(_ url:)`, aggiunto `.onOpenURL` in GardenCalendarApp, aggiornato `signUp` con `redirectTo: garden-calendar://auth-callback`
- **Guideline 2.1 demo account**: aggiunto remap credenziali in `LoginView.performLogin` (demo/demo → gardencalendar.demo@gmail.com / GardenDemo2026!), creato utente Supabase via REST API, confermato email via SQL editor (`UPDATE auth.users SET email_confirmed_at = NOW()`)
- Risolto errore build: `handle(url:)` → `handle(_ url:)` (no argument label in Supabase SDK 2.46)
- Build succeeded + app avviata su simulatore iPhone 17 Pro

## Decisioni prese

- Demo account usa remap lato client (pattern accettato da Apple per review): `demo`/`demo` → credenziali reali Supabase. Rischio basso (app dati personali giardinaggio, nessun dato sensibile del demo account).
- URL scheme scelto: `garden-calendar` → `garden-calendar://auth-callback`
- Supabase dashboard: aggiungere `garden-calendar://auth-callback` nei Redirect URLs (istruzione fornita all'utente).

## Prossimi passi

- Verificare test manuale login `demo`/`demo` sul simulatore
- Configurare redirect URL in Supabase dashboard (Authentication → URL Configuration)
- Rebuild release + resubmit su App Store Connect con note alla review

## Contesto tecnico rilevante

File modificati:
- `GardenCalendar/Info.plist` — aggiunto `CFBundleURLTypes` con scheme `garden-calendar`
- `GardenCalendar/Services/AuthManager.swift` — `signUp` + `handleDeepLink`
- `GardenCalendar/GardenCalendarApp.swift` — `.onOpenURL`
- `GardenCalendar/Views/Auth/LoginView.swift` — remap demo credentials

Supabase SDK: `client.auth.handle(_ url: URL)` — nonisolated, no await necessario
