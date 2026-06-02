# Rain Reschedule Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Quando la pioggia assorbe un'irrigazione ricorrente, spostare la prossima occorrenza a `data_pioggia + recurrence_days` e marcare l'attività assorbita con `rain_adjusted = rain_rescheduled = true`.

**Architecture:** La logica gira client-side in `CalendarGridView.loadMonth()`. `RainAdjuster` calcola le azioni di rescheduling. `SupabaseRepository` esegue i write. Il flag `rain_rescheduled = true` garantisce idempotenza: le attività già processate vengono saltate ad ogni reload.

**Tech Stack:** Swift 5.9, SwiftUI, Supabase Swift SDK, Open-Meteo API (già integrato)

> **Nota:** Il progetto non ha un test target XCTest. Le verifiche sono manuali tramite simulator.

---

### Task 1: Aggiunge `RescheduleAction` e `computeRescheduling()` a `RainAdjuster`

**Files:**
- Modify: `GardenCalendar/Services/RainAdjuster.swift`

- [ ] **Step 1: Aggiungi `RescheduleAction` struct dopo la chiusura di `RainAdjuster` (dopo la riga `}`  di `isIrrigation`)**

In `GardenCalendar/Services/RainAdjuster.swift`, dopo la riga 110 (chiusura di `struct RainAdjuster`), inserisci:

```swift
struct RescheduleAction {
    let absorbedId: UUID
    let absorbedDate: Date   // data dell'attività assorbita (non la data pioggia)
    let piantaId: UUID
    let nome: String
    let recurrenceDays: Int
    let rainDate: Date
    var newDate: Date {
        Calendar.current.date(byAdding: .day, value: recurrenceDays, to: rainDate)!
    }
}
```

- [ ] **Step 2: Aggiungi `computeRescheduling()` dentro `struct RainAdjuster`, dopo `computeOverrides()`**

Dentro `struct RainAdjuster` (dopo la chiusura di `computeOverrides` a riga ~104), inserisci:

```swift
static func computeRescheduling(
    activities: [Attivita],
    rainDays: [String: Bool]
) -> [RescheduleAction] {
    let calendar = Calendar.current
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate]

    return activities.compactMap { activity in
        guard !activity.userEvent,
              !activity.rainAdjusted,
              !activity.rainRescheduled,
              let recDays = activity.recurrenceDays, recDays > 0,
              isIrrigation(name: activity.nome)
        else { return nil }

        let actStr = formatter.string(from: activity.data)
        let dayBefore = calendar.date(byAdding: .day, value: -1, to: activity.data)!
        let dayBeforeStr = formatter.string(from: dayBefore)

        let rainDate: Date
        if rainDays[actStr] == true {
            rainDate = activity.data
        } else if rainDays[dayBeforeStr] == true {
            rainDate = dayBefore
        } else {
            return nil
        }

        return RescheduleAction(
            absorbedId: activity.id,
            absorbedDate: activity.data,
            piantaId: activity.piantaId,
            nome: activity.nome,
            recurrenceDays: recDays,
            rainDate: rainDate
        )
    }
}
```

- [ ] **Step 3: Verifica compilazione**

In Xcode: `Cmd+B`. Atteso: build succeeded, zero errori.

- [ ] **Step 4: Commit**

```bash
git add "GardenCalendar/Services/RainAdjuster.swift"
git commit -m "feat: add RescheduleAction and computeRescheduling to RainAdjuster"
```

---

### Task 2: Aggiunge 3 nuovi metodi a `SupabaseRepository`

**Files:**
- Modify: `GardenCalendar/Services/SupabaseRepository.swift`

- [ ] **Step 1: Aggiungi `fetchNextIrrigation()` dopo `rescheduleAttivita()` (riga ~188)**

In `GardenCalendar/Services/SupabaseRepository.swift`, dopo il metodo `rescheduleAttivita`, inserisci:

```swift
func fetchNextIrrigation(piantaId: UUID, nome: String, after: Date) async throws -> Attivita? {
    let results: [Attivita] = try await client
        .from("attivita")
        .select()
        .eq("pianta_id", value: piantaId)
        .eq("nome", value: nome)
        .gt("data", value: after)
        .eq("done", value: false)
        .order("data", ascending: true)
        .limit(1)
        .execute()
        .value
    return results.first
}
```

- [ ] **Step 2: Aggiungi `markRainAbsorbed()` subito dopo**

```swift
func markRainAbsorbed(id: UUID) async throws {
    struct Payload: Encodable {
        let rainAdjusted = true
        let rainRescheduled = true
        enum CodingKeys: String, CodingKey {
            case rainAdjusted = "rain_adjusted"
            case rainRescheduled = "rain_rescheduled"
        }
    }
    try await client
        .from("attivita")
        .update(Payload(), returning: .minimal)
        .eq("id", value: id)
        .execute()
}
```

- [ ] **Step 3: Aggiungi `rescheduleWithRain()` subito dopo**

```swift
func rescheduleWithRain(id: UUID, newDate: Date) async throws {
    struct Payload: Encodable { let data: Date }
    try await client
        .from("attivita")
        .update(Payload(data: newDate), returning: .minimal)
        .eq("id", value: id)
        .execute()
}
```

- [ ] **Step 4: Verifica compilazione**

`Cmd+B`. Atteso: build succeeded.

- [ ] **Step 5: Commit**

```bash
git add "GardenCalendar/Services/SupabaseRepository.swift"
git commit -m "feat: add fetchNextIrrigation, markRainAbsorbed, rescheduleWithRain to repository"
```

---

### Task 3: Wiring in `CalendarGridView`

**Files:**
- Modify: `GardenCalendar/Views/Calendario/CalendarView.swift`

- [ ] **Step 1: Aggiungi metodo `applyRainRescheduling()` prima di `loadFiltersData()`**

In `GardenCalendar/Views/Calendario/CalendarView.swift`, prima del metodo `loadFiltersData()` (riga ~418), inserisci:

```swift
private func applyRainRescheduling() async {
    let cal = Calendar.current
    let components = cal.dateComponents([.year, .month], from: currentMonth)
    guard let from = cal.date(from: components),
          let to = cal.date(byAdding: .month, value: 1, to: from) else { return }

    var rainDays: [String: Bool] = [:]
    for orto in orti {
        guard let lat = orto.latitudine, let lon = orto.longitudine else { continue }
        let days = (try? await OpenMeteoClient.shared.fetchRainDays(
            latitude: lat, longitude: lon, from: from, to: to)) ?? [:]
        rainDays.merge(days) { existing, _ in existing }
    }

    let actions = RainAdjuster.computeRescheduling(activities: activities, rainDays: rainDays)
    guard !actions.isEmpty else { return }

    for action in actions {
        let nextActivity: Attivita? = activities
            .filter { $0.piantaId == action.piantaId && $0.nome == action.nome && $0.data > action.absorbedDate }
            .sorted { $0.data < $1.data }
            .first
            ?? (try? await repository.fetchNextIrrigation(
                piantaId: action.piantaId, nome: action.nome, after: action.absorbedDate))

        if let next = nextActivity {
            try? await repository.rescheduleWithRain(id: next.id, newDate: action.newDate)
        }
        try? await repository.markRainAbsorbed(id: action.absorbedId)
    }

    activities = (try? await repository.fetchAttivita(date: currentMonth)) ?? []
}
```

- [ ] **Step 2: Aggiorna `loadMonth()` per chiamare `applyRainRescheduling()`**

Sostituisci il metodo `loadMonth()` esistente (riga ~424):

```swift
private func loadMonth() async {
    isLoading = true
    activities = (try? await repository.fetchAttivita(date: currentMonth)) ?? []
    await applyRainRescheduling()
    isLoading = false
}
```

- [ ] **Step 3: Verifica compilazione**

`Cmd+B`. Atteso: build succeeded, zero warnings nuovi.

- [ ] **Step 4: Test manuale nel simulator**

1. Avvia il simulator su iPhone 15
2. Apri il calendario
3. Apri Xcode console — verifica nessun crash durante `loadMonth()`
4. Per testare con pioggia simulata: nel DB Supabase, trova un'attività irrigazione futura con `recurrence_days > 0`, imposta `rain_adjusted = false, rain_rescheduled = false`. Poi fai `fetchRainDays` restituire pioggia su quella data (puoi momentaneamente hardcodare `rainDays = ["YYYY-MM-DD": true]` in `applyRainRescheduling` per il test, poi rimuovi). Verifica che:
   - L'attività venga marcata `rain_adjusted = true, rain_rescheduled = true` nel DB
   - La prossima occorrenza abbia la data spostata a `data_pioggia + recurrence_days`
   - Il calendario mostri 💧 sul giorno assorbito

- [ ] **Step 5: Commit**

```bash
git add "GardenCalendar/Views/Calendario/CalendarView.swift"
git commit -m "feat: wire rain rescheduling in CalendarGridView.loadMonth"
```
