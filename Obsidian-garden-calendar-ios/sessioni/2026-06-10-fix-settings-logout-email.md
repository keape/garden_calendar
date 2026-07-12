# Fix SettingsView: email reale e logout funzionante

**Data:** 2026-06-10
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** bug
**Status:** complete
**Tags:** SwiftUI, AuthManager, SettingsView, Supabase, simulatore

## Cosa abbiamo fatto

- Verificato fix già applicati in sessione precedente: `@Environment(AuthManager.self)` aggiunto, `email = ""` al posto di hardcoded, `loadSettings()` legge `authManager.user?.email`
- `signOut()` de-commentato e wrappato in `Task { await authManager.signOut() }`
- Build completata (exit code 0) su iPhone 16 simulatore
- App installata e lanciata (PID 8829) su simulatore Booted (bundle ID: `com.gardencalendar.app`)

## Decisioni prese

- Navigazione post-logout gestita da `ContentView` già esistente: quando `isAuthenticated → false`, mostra `LoginView` automaticamente — nessuna logica extra in `SettingsView`.

## Prossimi passi

- Testare manualmente: login → Impostazioni → verifica email visualizzata → logout → verifica redirect a LoginView.

## Contesto tecnico rilevante

File toccato: `GardenCalendar/Views/Settings/SettingsView.swift`
Bundle ID reale: `com.gardencalendar.app`
Simulatore: iPhone 16 (413E3B7E-DA84-4606-A5EA-884C1BBE3113)
