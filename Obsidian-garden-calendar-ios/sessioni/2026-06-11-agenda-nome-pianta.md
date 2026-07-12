# Agenda: mostra nome pianta per ogni attività

**Data:** 2026-06-11
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** bug
**Status:** complete
**Tags:** SwiftUI, iOS, CalendarView, DayActivityRow, agenda

## Cosa abbiamo fatto

- Identificato che `DayActivityRow` in `agendaContent` veniva chiamato senza `piantaNome`
- Il componente aveva già il parametro e la logica per mostrarlo, mancava solo il lookup
- Fix: passato `piante.first(where: { $0.id == activity.piantaId })?.nomePersonalizzato` in `CalendarView.swift` riga ~495
- Testato nel simulatore iPhone 16 (booted): agenda mostra correttamente "Irrigazione / Peperone", "Irrigazione / Basilico" ecc.

## Decisioni prese

- Fix minimale: zero refactor, zero nuove funzioni — solo il parametro mancante nel call site.

## Prossimi passi

- Nessun follow-up aperto.

## Contesto tecnico rilevante

File modificato: `GardenCalendar/Views/Calendario/CalendarView.swift`

Prima:
```swift
DayActivityRow(activity: activity)
```

Dopo:
```swift
DayActivityRow(
    activity: activity,
    piantaNome: piante.first(where: { $0.id == activity.piantaId })?.nomePersonalizzato
)
```
