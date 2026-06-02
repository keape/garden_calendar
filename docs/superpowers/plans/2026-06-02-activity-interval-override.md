# Activity Interval Override Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Permettere all'utente di sovrascrivere `recurrence_days` e/o `offset_days` di qualsiasi attività per una specifica pianta coltivata, con cancellazione e rigenerazione delle attività future.

**Architecture:** Colonna `activity_overrides jsonb` su `piante_coltivate` memorizza gli override per pianta. Un nuovo metodo `rescheduleActivity` nel repository cancella le occorrenze future di un tipo di attività e le rigenera client-side con i nuovi valori. La UI espone un sheet da `PiantaDetailView` con uno Stepper per modificare l'intervallo.

**Tech Stack:** Swift 5.9 + SwiftUI, Supabase Swift SDK (`@Observable`), PostgreSQL (Supabase hosted), Edge Functions Deno/TypeScript (non modificate in questo piano).

---

## File Map

| File | Azione | Responsabilità |
|------|--------|----------------|
| `supabase/migrations/20260602000001_activity_overrides.sql` | Crea | ALTER TABLE per aggiungere `activity_overrides jsonb` |
| `GardenCalendar/Models/PiantaColtivata.swift` | Modifica | Aggiungi `ActivityOverride` struct + campo `activityOverrides` |
| `GardenCalendar/Services/SupabaseRepository.swift` | Modifica | `updateActivityOverrides`, `rescheduleActivity`, `fetchPianta`, `fetchPlantKnowledge` |
| `GardenCalendar/Views/Piante/ModificaIntervalloSheet.swift` | Crea | Sheet per editing intervallo attività |
| `GardenCalendar/Views/Piante/PiantaDetailView.swift` | Modifica | `@State var pianta`, button ⓘ, `.sheet`, reload su dismiss |

---

## Task 1: Migration SQL

**Files:**
- Create: `supabase/migrations/20260602000001_activity_overrides.sql`

- [ ] **Step 1: Crea il file di migration**

```sql
-- Migration: aggiunge colonna activity_overrides a piante_coltivate
-- Struttura: [{"nome": "Irrigazione", "recurrence_days": 4}, {"nome": "Raccolta", "offset_days": 85}]
alter table piante_coltivate
  add column activity_overrides jsonb;
```

- [ ] **Step 2: Applica in Supabase**

Opzione A — Dashboard: Supabase Dashboard → SQL Editor → incolla e esegui.
Opzione B — CLI: `supabase db push` (se CLI configurata).

- [ ] **Step 3: Verifica**

Nel Table Editor Supabase, `piante_coltivate` deve avere la colonna `activity_overrides` di tipo `jsonb`, nullable, default NULL.

- [ ] **Step 4: Commit**

```bash
git add supabase/migrations/20260602000001_activity_overrides.sql
git commit -m "feat: add activity_overrides jsonb column to piante_coltivate"
```

---

## Task 2: PiantaColtivata Model

**Files:**
- Modify: `GardenCalendar/Models/PiantaColtivata.swift`

- [ ] **Step 1: Sostituisci il contenuto del file**

Il file intero diventa:

```swift
import Foundation

struct PiantaColtivata: Codable, Identifiable, Hashable {
    let id: UUID
    let ortoId: UUID
    let specieId: UUID?
    let nomePersonalizzato: String
    let dataSemina: Date
    let growthDays: Int
    let note: String?
    let fotoUrl: String?
    let activityOverrides: [ActivityOverride]?
    let createdAt: Date
    let updatedAt: Date

    struct ActivityOverride: Codable, Hashable {
        let nome: String
        var recurrenceDays: Int?
        var offsetDays: Int?

        enum CodingKeys: String, CodingKey {
            case nome
            case recurrenceDays = "recurrence_days"
            case offsetDays = "offset_days"
        }
    }

    var dataRaccoltaPrevista: Date {
        Calendar.current.date(byAdding: .day, value: growthDays, to: dataSemina) ?? dataSemina
    }

    enum CodingKeys: String, CodingKey {
        case id
        case ortoId = "orto_id"
        case specieId = "specie_id"
        case nomePersonalizzato = "nome_personalizzato"
        case dataSemina = "data_semina"
        case growthDays = "growth_days"
        case note
        case fotoUrl = "foto_url"
        case activityOverrides = "activity_overrides"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var giorniTrascorsi: Int {
        Calendar.current.dateComponents([.day], from: dataSemina, to: Date()).day ?? 0
    }

    var progressoCiclo: Double {
        guard growthDays > 0 else { return 0 }
        return min(Double(giorniTrascorsi) / Double(growthDays), 1.0)
    }
}

// MARK: - DTO per le mutate API

extension PiantaColtivata {
    struct Create: Encodable {
        let ortoId: UUID
        let specieId: UUID?
        let nomePersonalizzato: String
        let dataSemina: Date
        let growthDays: Int
        let note: String?
        let fotoUrl: String?

        enum CodingKeys: String, CodingKey {
            case ortoId = "orto_id"
            case specieId = "specie_id"
            case nomePersonalizzato = "nome_personalizzato"
            case dataSemina = "data_semina"
            case growthDays = "growth_days"
            case note
            case fotoUrl = "foto_url"
        }
    }

    struct Update: Encodable {
        let nomePersonalizzato: String?
        let dataSemina: Date?
        let growthDays: Int?
        let note: String?
        let fotoUrl: String?

        enum CodingKeys: String, CodingKey {
            case nomePersonalizzato = "nome_personalizzato"
            case dataSemina = "data_semina"
            case growthDays = "growth_days"
            case note
            case fotoUrl = "foto_url"
        }
    }
}
```

**Nota:** `PiantaColtivata.Update` non include `activityOverrides` — aggiorniamo gli override tramite un metodo dedicato nel repository per evitare che campi `nil` azzerino accidentalmente altri campi in un PATCH.

- [ ] **Step 2: Compila in Xcode**

`Cmd+B`. Deve compilare senza errori. Nessun call-site usa `activityOverrides` ancora.

- [ ] **Step 3: Commit**

```bash
git add GardenCalendar/Models/PiantaColtivata.swift
git commit -m "feat: add ActivityOverride nested type to PiantaColtivata"
```

---

## Task 3: SupabaseRepository — Nuovi Metodi

**Files:**
- Modify: `GardenCalendar/Services/SupabaseRepository.swift`

Aggiungi quattro metodi dopo la sezione `// MARK: - Catalogo / PlantKnowledge` (prima di `// MARK: - Forward Scheduling`).

- [ ] **Step 1: Aggiungi `fetchPianta(id:)` e `fetchPlantKnowledge(id:)`**

Inserisci dopo il metodo `searchCatalogo`:

```swift
func fetchPianta(id: UUID) async throws -> PiantaColtivata {
    try await client
        .from("piante_coltivate")
        .select()
        .eq("id", value: id)
        .single()
        .execute()
        .value
}

func fetchPlantKnowledge(id: UUID) async throws -> PlantKnowledge {
    try await client
        .from("plant_knowledge")
        .select()
        .eq("id", value: id)
        .single()
        .execute()
        .value
}
```

- [ ] **Step 2: Aggiungi `updateActivityOverrides(piantaId:overrides:)`**

Inserisci dopo i due metodi del passo precedente:

```swift
// MARK: - Activity Overrides

func updateActivityOverrides(piantaId: UUID, overrides: [PiantaColtivata.ActivityOverride]) async throws {
    struct OverrideUpdate: Encodable {
        let activityOverrides: [PiantaColtivata.ActivityOverride]
        enum CodingKeys: String, CodingKey { case activityOverrides = "activity_overrides" }
    }
    try await client
        .from("piante_coltivate")
        .update(OverrideUpdate(activityOverrides: overrides), returning: .minimal)
        .eq("id", value: piantaId)
        .execute()
}
```

- [ ] **Step 3: Aggiungi `rescheduleActivity(piantaId:dataSemina:growthDays:activity:)`**

Inserisci immediatamente dopo `updateActivityOverrides`:

```swift
func rescheduleActivity(
    piantaId: UUID,
    dataSemina: Date,
    growthDays: Int,
    activity: ScheduledTemplateActivity
) async throws {
    let today = Calendar.current.startOfDay(for: Date())

    // Cancella occorrenze future non completate per questo tipo di attività
    try await client
        .from("attivita")
        .delete()
        .eq("pianta_id", value: piantaId)
        .eq("nome", value: activity.nome)
        .eq("done", value: false)
        .gte("data", value: today)
        .execute()

    // Genera nuove occorrenze (replica logica Edge Function per singola attività)
    let plantLifespan = max(growthDays, 30)
    let endDate = Calendar.current.date(byAdding: .day, value: plantLifespan, to: dataSemina)!
    let baseDate = Calendar.current.date(byAdding: .day, value: activity.offsetDays, to: dataSemina)!

    var toInsert: [Attivita.Create] = []

    if let recurrenceDays = activity.recurrenceDays, recurrenceDays > 0 {
        var occurrence = baseDate
        while occurrence <= endDate {
            if occurrence >= today {
                toInsert.append(Attivita.Create(
                    piantaId: piantaId,
                    nome: activity.nome,
                    data: occurrence,
                    done: false,
                    rainAdjusted: false,
                    rainRescheduled: false,
                    userEvent: false,
                    sourceAction: "override",
                    note: nil,
                    color: activity.color,
                    recurrenceDays: recurrenceDays
                ))
            }
            occurrence = Calendar.current.date(byAdding: .day, value: recurrenceDays, to: occurrence)!
        }
    } else if activity.offsetDays <= plantLifespan && baseDate >= today {
        toInsert.append(Attivita.Create(
            piantaId: piantaId,
            nome: activity.nome,
            data: baseDate,
            done: false,
            rainAdjusted: false,
            rainRescheduled: false,
            userEvent: false,
            sourceAction: "override",
            note: nil,
            color: activity.color,
            recurrenceDays: nil
        ))
    }

    for att in toInsert {
        _ = try await createAttivita(attivita: att)
    }
}
```

- [ ] **Step 4: Compila in Xcode**

`Cmd+B`. Nessun errore atteso.

- [ ] **Step 5: Commit**

```bash
git add GardenCalendar/Services/SupabaseRepository.swift
git commit -m "feat: add fetchPianta, fetchPlantKnowledge, updateActivityOverrides, rescheduleActivity to repository"
```

---

## Task 4: ModificaIntervalloSheet

**Files:**
- Create: `GardenCalendar/Views/Piante/ModificaIntervalloSheet.swift`

- [ ] **Step 1: Crea il file**

```swift
import SwiftUI

struct ModificaIntervalloSheet: View {
    let pianta: PiantaColtivata
    let attivita: Attivita
    let tutteAttivita: [Attivita]

    @Environment(SupabaseRepository.self) private var repository
    @Environment(\.dismiss) private var dismiss

    @State private var valore: Int
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    private var isRicorrente: Bool { attivita.recurrenceDays != nil }

    init(pianta: PiantaColtivata, attivita: Attivita, tutteAttivita: [Attivita]) {
        self.pianta = pianta
        self.attivita = attivita
        self.tutteAttivita = tutteAttivita

        let existingOverride = pianta.activityOverrides?.first { $0.nome == attivita.nome }

        if attivita.recurrenceDays != nil {
            _valore = State(initialValue: existingOverride?.recurrenceDays ?? attivita.recurrenceDays ?? 1)
        } else {
            let firstDate = tutteAttivita
                .filter { $0.nome == attivita.nome }
                .map { $0.data }
                .min() ?? attivita.data
            let computed = Calendar.current.dateComponents([.day], from: pianta.dataSemina, to: firstDate).day ?? 0
            _valore = State(initialValue: existingOverride?.offsetDays ?? max(computed, 0))
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if isRicorrente {
                        Stepper("Ogni \(valore) giorni", value: $valore, in: 1...365)
                    } else {
                        Stepper("Dopo \(valore) giorni dalla semina", value: $valore, in: 0...730)
                    }
                } header: {
                    Text(attivita.nome.capitalized)
                }

                Section {
                    Button("Ripristina default", role: .destructive) {
                        Task { await ripristinaDefault() }
                    }
                    .disabled(pianta.specieId == nil)
                }
            }
            .navigationTitle("Modifica intervallo")
            .navigationBarTitleDisplayMode(.inline)
            .disabled(isLoading)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Salva") {
                            Task { await salva() }
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .alert("Errore", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Helpers

    private func currentOffsetDays() -> Int {
        let firstDate = tutteAttivita
            .filter { $0.nome == attivita.nome }
            .map { $0.data }
            .min() ?? attivita.data
        return max(Calendar.current.dateComponents([.day], from: pianta.dataSemina, to: firstDate).day ?? 0, 0)
    }

    private func buildActivity(recurrenceDays: Int?, offsetDays: Int) -> SupabaseRepository.ScheduledTemplateActivity {
        SupabaseRepository.ScheduledTemplateActivity(
            nome: attivita.nome,
            offsetDays: offsetDays,
            recurrenceDays: recurrenceDays,
            color: attivita.color
        )
    }

    // MARK: - Actions

    private func salva() async {
        isLoading = true
        defer { isLoading = false }
        do {
            var overrides = pianta.activityOverrides ?? []
            overrides.removeAll { $0.nome == attivita.nome }
            if isRicorrente {
                overrides.append(PiantaColtivata.ActivityOverride(nome: attivita.nome, recurrenceDays: valore, offsetDays: nil))
            } else {
                overrides.append(PiantaColtivata.ActivityOverride(nome: attivita.nome, recurrenceDays: nil, offsetDays: valore))
            }
            try await repository.updateActivityOverrides(piantaId: pianta.id, overrides: overrides)
            let activity = buildActivity(
                recurrenceDays: isRicorrente ? valore : attivita.recurrenceDays,
                offsetDays: isRicorrente ? currentOffsetDays() : valore
            )
            try await repository.rescheduleActivity(
                piantaId: pianta.id,
                dataSemina: pianta.dataSemina,
                growthDays: pianta.growthDays,
                activity: activity
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func ripristinaDefault() async {
        guard let specieId = pianta.specieId else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            var overrides = pianta.activityOverrides ?? []
            overrides.removeAll { $0.nome == attivita.nome }
            try await repository.updateActivityOverrides(piantaId: pianta.id, overrides: overrides)

            let knowledge = try await repository.fetchPlantKnowledge(id: specieId)
            if let def = knowledge.attivitaSuggeriteDecodificate.first(where: { $0.nome == attivita.nome }) {
                let activity = buildActivity(recurrenceDays: def.recurrenceDays, offsetDays: def.offsetDays)
                try await repository.rescheduleActivity(
                    piantaId: pianta.id,
                    dataSemina: pianta.dataSemina,
                    growthDays: pianta.growthDays,
                    activity: activity
                )
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
```

- [ ] **Step 2: Aggiungi il file al target Xcode**

In Xcode: tasto destro su `GardenCalendar/Views/Piante` → "Add Files to GardenCalendar..." → seleziona `ModificaIntervalloSheet.swift` → assicurati che il target `GardenCalendar` sia spuntato.

- [ ] **Step 3: Compila in Xcode**

`Cmd+B`. Nessun errore atteso.

- [ ] **Step 4: Commit**

```bash
git add "GardenCalendar/Views/Piante/ModificaIntervalloSheet.swift"
git commit -m "feat: add ModificaIntervalloSheet for per-plant activity interval override"
```

---

## Task 5: PiantaDetailView — Wire Up Sheet

**Files:**
- Modify: `GardenCalendar/Views/Piante/PiantaDetailView.swift`

- [ ] **Step 1: Sostituisci il contenuto del file**

```swift
import SwiftUI

struct PiantaDetailView: View {
    @State private var pianta: PiantaColtivata
    @Environment(SupabaseRepository.self) private var repository
    @State private var attivita: [Attivita] = []
    @State private var attivitaSelezionata: Attivita?

    init(pianta: PiantaColtivata) {
        _pianta = State(initialValue: pianta)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                    .padding(.horizontal)

                progressSection
                    .padding(.horizontal)

                activitiesSection
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(pianta.nomePersonalizzato)
        .navigationBarTitleDisplayMode(.large)
        .task { await loadData() }
        .refreshable { await loadData() }
        .sheet(item: $attivitaSelezionata, onDismiss: { Task { await loadData() } }) { att in
            ModificaIntervalloSheet(pianta: pianta, attivita: att, tutteAttivita: attivita)
                .environment(repository)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.primaryGreen.opacity(0.25), AppTheme.primaryGreen.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(AppTheme.primaryGreen)
            }

            HStack(spacing: 16) {
                Label("\(pianta.giorniTrascorsi)g / \(pianta.growthDays)g", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label("\(attivita.count) attività", systemImage: "checklist")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(spacing: 4) {
            ProgressView(value: pianta.progressoCiclo)
                .tint(pianta.progressoCiclo >= 1.0 ? AppTheme.accentAmbra : AppTheme.primaryGreen)
                .scaleEffect(x: 1, y: 2, anchor: .center)

            HStack {
                Text(pianta.dataSemina, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(pianta.progressoCiclo >= 1.0 ? "Completato! 🎉" : "\(Int(pianta.progressoCiclo * 100))%")
                    .font(.caption2.bold())
                    .foregroundStyle(AppTheme.primaryGreen)
                Spacer()
                Text(pianta.dataRaccoltaPrevista, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }

    // MARK: - Activities Section

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📋 Attività")
                .font(.headline)

            if attivita.isEmpty {
                Text("Nessuna attività registrata per questa pianta.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            }

            let today = Calendar.current.startOfDay(for: Date())
            let future = attivita.filter { !$0.done && $0.data >= today }
            let past = attivita.filter { $0.done || $0.data < today }

            if !future.isEmpty {
                Text("In programma")
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.primaryGreen)

                ForEach(future) { att in
                    AttivitaRow(
                        attivita: att,
                        onToggle: { toggleDone(att) },
                        onInfo: { attivitaSelezionata = att }
                    )
                }
            }

            if !past.isEmpty {
                Text("Completate / Passate")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)

                ForEach(past) { att in
                    AttivitaRow(
                        attivita: att,
                        onToggle: { toggleDone(att) },
                        onInfo: { attivitaSelezionata = att }
                    )
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }

    // MARK: - Helpers

    private func loadData() async {
        do {
            async let attivitaFetch = repository.fetchAttivita(piantaId: pianta.id)
            async let piantaFetch = repository.fetchPianta(id: pianta.id)
            let (fetchedAttivita, fetchedPianta) = try await (attivitaFetch, piantaFetch)
            attivita = fetchedAttivita
            pianta = fetchedPianta
        } catch {}
    }

    private func toggleDone(_ att: Attivita) {
        if let i = attivita.firstIndex(where: { $0.id == att.id }) {
            attivita[i].done.toggle()
        }
        Task { try? await repository.setDone(id: att.id, done: !att.done) }
    }
}

// MARK: - Attività Row

struct AttivitaRow: View {
    let attivita: Attivita
    let onToggle: () -> Void
    let onInfo: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: attivita.done ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(attivita.done ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            ActivityColorDot(activityName: attivita.nome, size: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(attivita.nome.capitalized)
                    .font(.subheadline)
                    .strikethrough(attivita.done)

                Text(attivita.data, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if attivita.recurrenceDays != nil {
                    Label("Ricorrente", systemImage: "repeat")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(action: onInfo) {
                Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
                    .font(.body)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        PiantaDetailView(pianta: PiantaColtivata(
            id: UUID(),
            ortoId: UUID(),
            specieId: nil,
            nomePersonalizzato: "Pomodoro",
            dataSemina: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
            growthDays: 90,
            note: nil,
            fotoUrl: nil,
            activityOverrides: nil,
            createdAt: Date(),
            updatedAt: Date()
        ))
        .environment(SupabaseRepository.shared)
    }
}
```

- [ ] **Step 2: Compila in Xcode**

`Cmd+B`. Nessun errore atteso.

- [ ] **Step 3: Test manuale nel Simulator**

1. Avvia l'app nel Simulator
2. Vai su una pianta con attività schedulate
3. Verifica che ogni riga mostri il button ⓘ a destra
4. Tappa ⓘ su un'attività ricorrente (es. "Irrigazione") → deve aprirsi `ModificaIntervalloSheet` con lo Stepper pre-popolato
5. Cambia il valore (es. da 3 a 5) → tappa "Salva"
6. Attendi il dismiss → verifica che `loadData()` ricarichi la lista con le nuove date di irrigazione
7. Riapri ⓘ → lo Stepper deve mostrare il nuovo valore (5)
8. Tappa ⓘ su un'attività una-tantum (es. "Raccolta") → Stepper deve mostrare giorni dalla semina
9. Tappa "Ripristina default" (solo se la pianta ha `specieId`) → deve tornare al valore catalogo

- [ ] **Step 4: Commit**

```bash
git add "GardenCalendar/Views/Piante/PiantaDetailView.swift"
git commit -m "feat: wire ModificaIntervalloSheet in PiantaDetailView with per-plant activity override"
```

---

## Self-Review Checklist

- [x] **Spec coverage:** DB (Task 1) ✓ · Model (Task 2) ✓ · Repository (Task 3) ✓ · Sheet UI (Task 4) ✓ · PiantaDetailView wire-up (Task 5) ✓
- [x] **Placeholder scan:** nessun TBD o TODO nel piano
- [x] **Type consistency:** `PiantaColtivata.ActivityOverride`, `SupabaseRepository.ScheduledTemplateActivity`, `updateActivityOverrides`, `rescheduleActivity`, `fetchPianta`, `fetchPlantKnowledge` — tutti definiti in Task 2-3 e usati in Task 4-5 con gli stessi nomi
- [x] **Edge case "Ripristina default" su pianta senza specieId:** button disabilitato (Task 4, `pianta.specieId == nil`)
- [x] **Reload pianta dopo dismiss sheet:** `loadData()` ora chiama `fetchPianta` in parallelo (Task 5), garantendo `activityOverrides` aggiornati al prossimo open sheet
