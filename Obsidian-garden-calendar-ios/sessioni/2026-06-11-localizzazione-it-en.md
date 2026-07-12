# Localizzazione IT/EN completa — LanguageManager + Strings

**Data:** 2026-06-11
**Progetto:** garden-calendar-ios
**Durata:** lunga
**Tipo:** feature
**Status:** complete
**Tags:** swiftui, localization, observable, subagent-driven-development, strings

## Cosa abbiamo fatto

- Creato `GardenCalendar/Localization/Strings.swift`: `AppLanguage` enum, `Strings` struct con 10 namespace sub-struct, istanze statiche `italian`/`english` (garanzia compile-time), `@Observable LanguageManager` singleton con persistenza `UserDefaults`
- Iniettato `LanguageManager` in `GardenCalendarApp.swift` + `ContentView.swift`
- Aggiunto language picker in `SettingsView` (sopra "Aspetto"), switch istantaneo senza restart
- Localizzati 16 file view: Auth, Settings, Calendar, DayDetail, Plants (6 file), Garden (2), Journal, NotificationManager
- Fix bug `alertMessage.contains("salvato/successo")` → pattern `@State private var alertIsSuccess = false` in `AggiungiPiantaView` e `QuickJournalView`
- Fix gap residui: `ProgressView("Caricamento…")` → `lang.common.loading`, `Label("\(piante.count) piante")` → `lang.garden.plantsCountFormat`
- Push su `origin/main` (10 commit)

## Decisioni prese

- **`@Observable` non `ObservableObject`**: propagazione automatica senza `@Published`, pattern moderno Swift 5.9+
- **Struct tipizzate** invece di `[String: String]` dizionari: errori a compile-time se manca una chiave
- **`LanguageManager.shared` in contesti non-SwiftUI** (Task closures, `stepTitle`, `NotificationManager`): accesso diretto al singleton, `lang` environment solo nei body SwiftUI
- **`ViewMode` rawValues** cambiati da nomi display italiani a chiavi neutre `"calendar"`/`"agenda"` per evitare dipendenza lingua nei confronti
- **`tipologie` e `weekDays`** cambiate da `let` costanti a `var` computed properties per referenziare `lang`
- **Subagent-Driven Development**: un subagent per task + spec review + quality review per ogni task

## Prossimi passi

- `gardenOptions` mock in `SettingsView` (array `["Il mio orto", "Orto sul balcone", "Giardino"]`) ancora hardcoded italiano — placeholder pre-esistente, bassa priorità
- Testare switch lingua su device fisico per verificare instant update in tutte le schermate

## Contesto tecnico rilevante

File chiave:
- `GardenCalendar/Localization/Strings.swift` — unica fonte di verità per tutte le stringhe
- Pattern view: `@Environment(LanguageManager.self) private var lang`
- Pattern non-SwiftUI: `LanguageManager.shared.notifications.dailyTitle`
- Format string: `String(format: lang.garden.deleteConfirmMsgFormat, orto.nome)`
