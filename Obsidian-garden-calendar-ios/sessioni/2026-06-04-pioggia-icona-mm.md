# Icona pioggia visibilità + mm reali nel calendario

**Data:** 2026-06-04
**Progetto:** garden-calendar-ios
**Durata:** media
**Tipo:** feature
**Status:** complete
**Tags:** SwiftUI, OpenMeteo, CalendarView, DayDetailSheet, SF-Symbols

## Cosa abbiamo fatto

- Cambiato `[String: Bool]` → `[String: Double]` in `RainAdjuster.fetchRainDays` per salvare i mm reali invece di un flag booleano
- Aggiornati tutti i siti che usano `rainDays`: `CalendarView`, `DayDetailSheet`, `RainAdjuster` (isAbsorbedByRain, computeOverrides, computeRescheduling)
- Sostituita emoji `💧` nel grid con `Image(systemName: "cloud.rain.fill")` + testo mm sotto
- Aggiunto `.symbolRenderingMode(.monochrome)` a `WeatherIcon` e all'icona nel grid — prima `.multicolor` sovrascriveva `foregroundStyle` rendendo l'icona quasi invisibile su sfondo bianco
- `DayDetailSheet` mostra mm reali del giorno selezionato (non max con ieri)
- Rimossa logica "Ieri: X.X mm" — ogni giorno mostra solo la pioggia caduta quel giorno

## Decisioni prese

- Display pioggia = solo `selectedDate`, non max(oggi, ieri): la logica "ieri ha piovuto → irrigazione assorbita" serve al scheduler, non al display utente
- Merge multi-orto usa `max` tra orti diversi per stesso giorno (caso raro ma corretto)
- `.monochrome` su tutti i simboli meteo per garantire colore esplicito (`AppTheme.rainBlue`)

## Prossimi passi

- Nessun follow-up aperto.

## Contesto tecnico rilevante

File modificati:
- `GardenCalendar/Services/RainAdjuster.swift` — tipo ritorno e cache `[String: Double]`
- `GardenCalendar/Views/Calendario/CalendarView.swift` — stato, icona, merge
- `GardenCalendar/Views/Calendario/DayDetailSheet.swift` — display mm solo oggi
- `GardenCalendar/Views/Components/WeatherIcon.swift` — `.symbolRenderingMode(.monochrome)`
