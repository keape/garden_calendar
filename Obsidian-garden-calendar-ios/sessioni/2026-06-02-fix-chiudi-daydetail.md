# Fix pulsante Chiudi in DayDetailSheet

**Data:** 2026-06-02
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** bug
**Status:** complete
**Tags:** SwiftUI, iOS, simulator, xcodebuild, DayDetailSheet

## Cosa abbiamo fatto

- Identificato bug: pulsante "Chiudi" in `DayDetailSheet` chiamava `showQuickJournal = false` invece di chiudere il sheet
- Aggiunto `@Environment(\.dismiss) private var dismiss` alla view
- Sostituito `showQuickJournal = false` con `dismiss()` nel toolbar button
- Build con `xcodebuild` su simulatore "Test" (iOS 18.5, UDID: 347C86A2)
- Installato e lanciato app sul simulatore, screenshot confermato fix presente

## Decisioni prese

- Usato `@Environment(\.dismiss)` standard SwiftUI anziché passare binding dall'esterno — approccio più idiomatico per sheet presentati con `.sheet()`.

## Prossimi passi

- Nessun follow-up aperto.

## Contesto tecnico rilevante

- File modificato: `GardenCalendar/Views/Calendario/DayDetailSheet.swift` (riga 8 + riga 140)
- Simulatore: "Test" iOS 18.5, UDID `347C86A2-71AD-48EA-BFC6-38BB624202E8`
- Build: `xcodebuild -project GardenCalendar.xcodeproj -scheme GardenCalendar -destination "id=..." -configuration Debug build`
