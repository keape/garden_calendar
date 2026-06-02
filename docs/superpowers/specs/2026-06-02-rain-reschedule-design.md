# Rain Reschedule — Design Spec
_2026-06-02_

## Problema

Quando piove il giorno di un'irrigazione programmata (o il giorno prima), l'irrigazione viene assorbita dalla pioggia. Attualmente i flag `rain_adjusted`/`rain_rescheduled` esistono nel modello ma non vengono mai scritti, e la prossima occorrenza dell'irrigazione non viene spostata. L'utente potrebbe irrigare inutilmente il giorno successivo.

## Comportamento atteso

Se piove il giorno X (o X+1 è assorbito da pioggia del giorno X):
- L'irrigazione assorbita viene marcata `rain_adjusted = true, rain_rescheduled = true`
- La prossima occorrenza viene spostata a `data_pioggia + recurrence_days`
- Esempio: pioggia il giorno 2, irrigazione ogni 3 giorni programmata il giorno 3 → assorbita → prossima = giorno 2 + 3 = giorno 5

## Architettura

### File modificati

| File | Cambiamento |
|------|-------------|
| `GardenCalendar/Services/RainAdjuster.swift` | Aggiunge `RescheduleAction` + `computeRescheduling()` |
| `GardenCalendar/Services/SupabaseRepository.swift` | Aggiunge `fetchNextIrrigation()`, `markRainAbsorbed()`, `rescheduleWithRain()` |
| `GardenCalendar/Views/Calendario/CalendarView.swift` | Aggiunge `applyRainRescheduling()`, chiamato da `loadMonth()` |

### Flusso dati (in `loadMonth()`)

```
fetchAttivita(month)
→ applyRainRescheduling()
    → costruisce mappa piantaId → (lat, lon) tramite orti/piante già caricati
    → per ogni orto con coordinate: OpenMeteoClient.fetchRainDays() [cacheato 6h]
    → RainAdjuster.computeRescheduling(activities, rainDays) → [RescheduleAction]
    → per ogni action:
        cerca next occurrence in activities già caricati (fallback: fetchNextIrrigation)
        rescheduleWithRain(nextId, newDate)
        markRainAbsorbed(absorbedId)
    → se azioni > 0: reload fetchAttivita(month)
```

## Strutture dati

### `RescheduleAction`

```swift
struct RescheduleAction {
    let absorbedId: UUID
    let piantaId: UUID
    let nome: String
    let recurrenceDays: Int
    let rainDate: Date
    var newDate: Date { Calendar.current.date(byAdding: .day, value: recurrenceDays, to: rainDate)! }
}
```

### `computeRescheduling()` — filtri di ingresso

Processa solo attività che soddisfano **tutte** le condizioni:
- `userEvent == false` (solo AI-suggested)
- `rainAdjusted == false` (non ancora processata)
- `rainRescheduled == false` (non già spostata)
- `recurrenceDays != nil && recurrenceDays > 0`
- `isIrrigation(nome) == true`
- Pioggia ≥ 2mm sul giorno dell'attività O sul giorno precedente

## Idempotenza

`markRainAbsorbed()` scrive `rain_adjusted = true` e `rain_rescheduled = true` nella stessa chiamata. Le successive esecuzioni di `loadMonth()` filtrano via le attività già processate (`rainAdjusted == false` guard). Nessun rischio di doppia rischedulazione.

## Gestione next occurrence oltre il mese corrente

1. Cerca prima in `activities` già caricato (stesso mese)
2. Fallback: `fetchNextIrrigation(piantaId, nome, after: absorbedDate)` — query DB con `data > absorbedDate, done = false, order ASC, limit 1`
3. Se non trovata: marca solo `rain_absorbed`, nessuna rischedulazione (attività già completata o pianta archiviata)

## Nuovi metodi Repository

```swift
fetchNextIrrigation(piantaId: UUID, nome: String, after: Date) async throws -> Attivita?
markRainAbsorbed(id: UUID) async throws          // rain_adjusted=true, rain_rescheduled=true
rescheduleWithRain(id: UUID, newDate: Date) async throws
```

## Casi limite

| Caso | Comportamento |
|------|---------------|
| Orto senza coordinate | Skip rain check per quell'orto |
| Next occurrence già `done` | `fetchNextIrrigation` filtra su `done = false` |
| Next occurrence non trovata | Solo `markRainAbsorbed`, nessun crash |
| Più orti con piogge diverse | Rain days uniti con `merge`, primo valore vince per date sovrapposte |
| Open-Meteo non disponibile | `try?` — skip silenzioso, nessun blocco UI |
