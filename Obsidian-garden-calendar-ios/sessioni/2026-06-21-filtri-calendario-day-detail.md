# Filtri calendario propagati a DayDetailView

**Data:** 2026-06-21
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** bug
**Status:** complete
**Tags:** SwiftUI, CalendarView, DayDetailView, filtri, simulatore

## Cosa abbiamo fatto

- Identificato bug: `DayDetailView` mostrava attività ignorate dai filtri attivi in `CalendarView`
- Causa: `loadActivities()` in `DayDetailSheet.swift` ricariava tutte le attività del giorno senza applicare filtri
- Aggiunto `filterPiantaIds: Set<UUID>?` e `filterTipologia: String?` come `let` a `DayDetailView`
- Modificato `loadActivities()` per filtrare per pianta e tipologia (colore) dopo il fetch
- In `CalendarView`, calcolo `filterPiantaIds` combinando filtro orto (lookup su `piante`) e filtro singola pianta
- Build + install + launch su simulatore iPhone 17 Pro confermato funzionante

## Decisioni prese

- Passare `Set<UUID>?` di piante ammesse invece di `filterOrtoId` diretto, perché `Attivita` non ha `ortoId` — il lookup orto→piante vive in `CalendarView` dove si ha `piante` in stato.
- Filtro tipologia mappato su `att.color.lowercased()` coerente con `filteredActivities` in `CalendarView`.

## Prossimi passi

- Nessun follow-up aperto.

## Contesto tecnico rilevante

File modificati:
- `GardenCalendar/Views/Calendario/DayDetailSheet.swift` — nuovi parametri init + filtro in loadActivities()
- `GardenCalendar/Views/Calendario/CalendarView.swift` — call site aggiornato con filterPiantaIds calcolato
