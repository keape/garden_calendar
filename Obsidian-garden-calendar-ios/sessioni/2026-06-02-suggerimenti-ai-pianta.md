# Fix suggerimenti AI: nome pianta e contraddizione semina/trapianto

**Data:** 2026-06-02
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** bug
**Status:** complete
**Tags:** SwiftUI, Supabase, DayDetailSheet, attivita, piante

## Cosa abbiamo fatto

- Identificato che `DayActivityRow` mostrava solo il tipo attività (es. "Semina") senza indicare a quale pianta si riferiva
- Aggiunto `@State private var pianteLookup: [UUID: String]` in `DayDetailSheet`
- `loadActivities()` ora fetcha anche `fetchAllPiante(userId:)` e costruisce il lookup `[UUID: String]`
- `DayActivityRow` aggiornato con parametro opzionale `piantaNome: String?`, visualizzato come caption sotto il titolo attività
- Aggiunto filtro in `aiActivities`: esclude "Semina" per piante che hanno già "Trapianto" nel journal dello stesso giorno

## Decisioni prese

- Lookup piante via `fetchAllPiante(userId:)` (fetch completo, non per singola pianta) — più semplice, accettabile dato numero piante ridotto
- Filtro contraddizione solo su coppia trapianto→semina (non esteso ad altre coppie per ora)

## Prossimi passi

- Valutare altre coppie contraddittorie (es. raccolta → non suggerire semina/trapianto)
- Verificare performance fetch piante su account con molti orti

## Contesto tecnico rilevante

File modificato: `GardenCalendar/Views/Calendario/DayDetailSheet.swift`

Logica filtro:
```swift
let trapiantoPiantaIds = Set(
    journalActivities
        .filter { $0.nome.lowercased() == "trapianto" }
        .map { $0.piantaId }
)
return activities.filter { !$0.userEvent }.filter { activity in
    !(activity.nome.lowercased() == "semina" && trapiantoPiantaIds.contains(activity.piantaId))
}
```
