# Design: Override periodicità attività per singola pianta

**Data:** 2026-06-02  
**Stato:** Approvato

## Contesto

`plant_knowledge.attivita_suggerite` definisce le attività di default per ogni specie (es. irrigazione ogni 3 giorni). Il valore è globale per specie: non era possibile personalizzarlo per una singola pianta coltivata.

## Obiettivo

Permettere all'utente di sovrascrivere `recurrence_days` e/o `offset_days` di qualsiasi attività (ricorrente o una-tantum) per una specifica `PiantaColtivata`. La modifica cancella e rigenera le attività future con il nuovo intervallo.

---

## 1. Database

**Migration:** aggiunge colonna nullable `activity_overrides jsonb` a `piante_coltivate`.

```sql
alter table piante_coltivate
  add column activity_overrides jsonb;
```

**Struttura JSON:**
```json
[
  { "nome": "Irrigazione", "recurrence_days": 4 },
  { "nome": "Concimazione", "offset_days": 25 }
]
```

- `nome`: obbligatorio, usato come chiave di match con `plant_knowledge.attivita_suggerite`
- `recurrence_days`: sovrascrive l'intervallo di ricorrenza (attività ricorrenti)
- `offset_days`: sovrascrive il giorno di prima occorrenza dalla semina (tutte le attività)
- Campi omessi: si usa il valore da `plant_knowledge`
- `null` (colonna): nessun override, comportamento invariato

**RLS:** le policy esistenti su `piante_coltivate` coprono già la nuova colonna.

---

## 2. Swift Models & Repository

**`PiantaColtivata`** — nuovo campo e struct annidato:

```swift
let activityOverrides: [ActivityOverride]?

struct ActivityOverride: Codable, Hashable {
    let nome: String
    var recurrenceDays: Int?
    var offsetDays: Int?
    // CodingKeys: recurrence_days, offset_days
}
```

`CodingKeys` di `PiantaColtivata` aggiunge `case activityOverrides = "activity_overrides"`.

**`PiantaColtivata.Update`** — aggiunge `let activityOverrides: [ActivityOverride]?`.

**`SupabaseRepository`** — nessun nuovo metodo. Flusso:
1. `updatePianta(id:update:)` — PATCH con nuovo `activityOverrides`
2. `scheduleActivities(...)` — già esistente, rigenera le attività future

---

## 3. Edge Function `schedule-activities`

**Nuovo campo nel body della request:**
```typescript
interface ScheduleRequest {
  pianta_id: string
  data_semina: string
  growth_days: number
  activities: TemplateActivity[]
  activity_overrides?: ActivityOverride[]  // nuovo, opzionale
}

interface ActivityOverride {
  nome: string
  recurrence_days?: number
  offset_days?: number
}
```

**Merge prima del loop di scheduling:**
```typescript
const mergedActivities = activities.map(act => {
  const override = activity_overrides?.find(o => o.nome === act.nome)
  if (!override) return act
  return {
    ...act,
    ...(override.recurrence_days !== undefined && { recurrence_days: override.recurrence_days }),
    ...(override.offset_days !== undefined && { offset_days: override.offset_days }),
  }
})
```

La cancellazione delle attività future è già gestita dalla funzione: nessuna logica extra.

**iOS:** `SupabaseRepository` legge `activity_overrides` dalla pianta e li include nel payload esistente alla Edge Function.

---

## 4. UI — `ModificaIntervalloSheet`

**Trigger:** button ⓘ aggiunto a destra di ogni `AttivitaRow` → apre sheet.  
`PiantaDetailView` gestisce con `@State private var attivitaSelezionata: Attivita?`.  
Il button ⓘ è visibile su tutte le righe (ricorrenti e una-tantum).

**Contenuto sheet:**
- Titolo: nome attività
- Se `recurrenceDays != nil`: `Stepper` "Ogni X giorni" (range 1–365), pre-popolato con override esistente o default da `plant_knowledge`
- Se una-tantum: `Stepper` "Dopo X giorni dalla semina"
- Bottone **Salva**: aggiorna override → rischedula → ricarica lista
- Bottone **Ripristina default**: rimuove l'entry dell'override per questa attività

**Flusso:**
```
Sheet.salva()
  → repository.updatePianta(override aggiornato)
  → repository.scheduleActivities(con nuovi overrides)
  → PiantaDetailView.loadData()
```

**Error handling:** errori mostrati con `Alert` standard. Se Edge Function fallisce dopo il PATCH, l'override è già persistito — al prossimo `loadData` / apertura app le attività vengono rigenerate correttamente.

---

## Decisioni chiave

| Decisione | Scelta | Motivo |
|-----------|--------|--------|
| Storage override | JSONB su `piante_coltivate` | 1 sola migration, pattern già usato nel progetto |
| Match attività | Per `nome` | Unico identificatore disponibile senza ID per le template |
| Attività future | Cancella + rigenera | Comportamento A scelto dall'utente |
| Scope campi override | Solo `recurrence_days` / `offset_days` | Scope minimo, nome e colore non personalizzabili |
