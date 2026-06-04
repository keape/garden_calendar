# Rain-aware irrigation rescheduling + weather icon fix

**Data:** 2026-06-04
**Progetto:** garden-calendar-ios
**Durata:** lunga
**Tipo:** feature
**Status:** complete
**Tags:** SwiftUI, OpenMeteo, iOS, RainAdjuster, simulator

## Cosa abbiamo fatto

- Investigato perché la feature di rescheduling irrigazione per pioggia non era visibile nell'app
- Confermato che `RainAdjuster.swift` + `applyRainRescheduling` esistevano già ma `rainDays` era variabile locale → non propagata alla UI
- Promosso `rainDays` a `@State` su `CalendarGridView`
- Esteso range fetch piogge da "inizio mese" a "7 giorni prima del mese"
- Aggiunto toast "N irrigazioni spostate per pioggia" con auto-dismiss 4s
- Aggiornato `cellView` per mostrare 💧 anche da dati Open-Meteo diretti (non solo flag DB)
- Fix WeatherIcon in `DayDetailSheet`: ora fetcha autonomamente i dati pioggia in `loadActivities` via `fetchRainStatus(orti:)` → evita problema propagazione SwiftUI `let` in sheet già presentato
- Verificato: coordinate orto = 41.3767°, 13.4445° → Open-Meteo conferma 9.7mm il 3 giugno 2026
- Testato su simulator: icona passa da ☀️ a 🌧 dopo ~3s (fetch API)

## Decisioni prese

- `DayDetailSheet` fetcha i propri dati pioggia autonomamente invece di riceverli dal parent: evita il bug SwiftUI dove `let` property non si aggiorna in sheet già presentato con `@State` interno.
- Soglia pioggia rimasta a 2mm (invariata da prima).

## Prossimi passi

- Verificare su device fisico (rebuild necessario, provisioning issue con xcodebuild CLI).
- Considerare loading indicator durante fetch pioggia nel DayDetailSheet (attualmente l'icona appare con ~3s ritardo senza feedback).

## Contesto tecnico rilevante

File modificati:
- `GardenCalendar/Views/Calendario/CalendarView.swift` — `@State rainDays`, toast, range -7gg, cellView
- `GardenCalendar/Views/Calendario/DayDetailSheet.swift` — `fetchRainStatus`, `@State isRainyDay`, rimosso parametro `rainDays`
- `GardenCalendar/Services/RainAdjuster.swift` — invariato (logica già corretta)
