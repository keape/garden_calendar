# Naturalista UX Redesign — implementazione completa

**Data:** 2026-06-04
**Progetto:** garden-calendar-ios
**Durata:** lunga
**Tipo:** feature
**Status:** complete
**Tags:** swiftui, apptheme, custom-fonts, subagent-driven, naturalista

## Cosa abbiamo fatto

- Scaricato e registrato font custom: Lora-Bold, DMSans-Regular/Medium/SemiBold (TTF in bundle Xcode + UIAppFonts in Info.plist)
- Aggiunto token colore AppTheme: backgroundCream, cardSecondaryWarm, textPrimary, textSecondary, ctaDarkGreen + Font helpers `Font.lora()` e `Font.dmSans()`
- CalendarView: sfondo crema, pill segmented control custom, `.sheet` → `.navigationDestination` push
- DayDetailView: Lora titles, DM Sans rows, CTA pill verde scuro, push navigation (ex sheet)
- OrtoListView: ScrollView+LazyVStack card layout con OrtoCardRow, contextMenu delete
- OrtoDetailView: tema crema, sezione Piante embedded, fix loadPiante errors + reload on dismiss
- PiantaListView + PiantaDetailView: tema crema, DM Sans fonts
- SettingsView: Form cream theme, sectionHeader helper con DM Sans
- LoginView + SignUpView: sfondo crema, Lora title, DM Sans fields, pill CTA, fix resetSent false success
- Graphify aggiornato post-implementazione

## Decisioni prese

- Push navigation (non sheet) per DayDetailView: `.onChange(of: showDayDetail)` replica `onDismiss` per reload
- `@ViewBuilder pillSegmentButton` estratto per evitare compiler type-check timeout su ternary nested in `.background`
- Action links auth (Registrati/Accedi) usano `primaryGreen` non `textSecondary` — scelta UX intenzionale per link interattivi
- Delete OrtoListView: ottimismo rimosso → remove solo su successo network, rollback su errore

## Prossimi passi

- `QuickJournalView` e `AggiungiPiantaView` non restyled (fuori scope) — candidati per sessione follow-up
- `PiantaDetailView.toggleDone` usa `try?` silente — bug pre-esistente da affrontare separatamente
- SettingsView logout button ancora stub (`authManager.signOut()` commentato)

## Contesto tecnico rilevante

Commit range: `ec4c8bd` → `HEAD` (12 commit feature + fix)
Esecuzione via `superpowers:subagent-driven-development` — fresh subagent per task + spec review + quality review per ogni task.
