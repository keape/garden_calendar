# Ripristino badge pioggia in DayDetailView

**Data:** 2026-06-04
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** bug
**Status:** complete
**Tags:** SwiftUI, OpenMeteo, DayDetailView, CalendarView, pioggia

## Cosa abbiamo fatto

- Identificato che il badge pioggia (icona + mm) era scomparso da `DayDetailView` dopo il restyling Naturalista
- `rainMm` e `fetchRainStatus` erano già presenti nel codice ma non renderizzati nella UI
- Aggiunto il badge rain nella `body` di `DayDetailView`, subito dopo la progress bar: icona `cloud.rain.fill` + testo `"X mm di pioggia"` visibile quando `rainMm > 0`
- Buildata l'app e lanciata su simulatore iPhone 16 (Booted)

## Decisioni prese

- Badge posizionato dopo la progress bar, allineato a sinistra, coerente con stile Naturalista (colore `AppTheme.rainBlue`, font `.dmSans`)

## Prossimi passi

- Verificare su un giorno con dati meteo reali (orto con coordinate) che `rainMm` venga popolato da OpenMeteo

## Contesto tecnico rilevante

- File modificato: `GardenCalendar/Views/Calendario/DayDetailSheet.swift`
- La logica fetch era in `fetchRainStatus(orti:)` chiamata da `loadActivities()` — nessuna modifica lì
- `CalendarView.swift` già mostrava icona+mm nelle celle — il `DayDetailSheet` era rimasto indietro
