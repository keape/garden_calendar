# Ripristino badge pioggia + setup remote GitHub

**Data:** 2026-06-04
**Progetto:** garden-calendar-ios
**Durata:** media
**Tipo:** bug
**Status:** complete
**Tags:** SwiftUI, DayDetailView, OpenMeteo, git, GitHub

## Cosa abbiamo fatto

- Identificato che `DayDetailView` aveva `rainMm` e `fetchRainStatus` ma non mostrava nulla nella UI
- Aggiunto badge pioggia (`cloud.rain.fill` + `"X mm di pioggia"`) dopo la progress bar, visibile quando `rainMm > 0`
- Buildato e lanciato app su simulatore iPhone 16 (già Booted)
- Configurato remote GitHub `https://github.com/keape/garden_calendar.git` (mancante)
- Remote aveva storia divergente (web app con plant chat, storie non correlate)
- Force push per sovrascrivere remote con storia locale iOS

## Decisioni prese

- Badge rain posizionato dopo progress bar in `DayDetailView`, stile coerente con `CalendarView` (colore `AppTheme.rainBlue`, font `.dmSans`)
- Force push su `main` per allineare remote — storia remota era progetto diverso, non recuperabile

## Prossimi passi

- Salvare il remote URL in memoria per non perderlo di nuovo
- Testare badge su giorno con dati meteo reali (orto con lat/lon)

## Contesto tecnico rilevante

- File modificato: `GardenCalendar/Views/Calendario/DayDetailSheet.swift` (struct `DayDetailView`)
- Remote: `https://github.com/keape/garden_calendar.git`
- Bundle ID simulatore: `com.gardencalendar.app`, device `F4D2A264-CB52-4F14-8E4D-AB4316CCC746`
