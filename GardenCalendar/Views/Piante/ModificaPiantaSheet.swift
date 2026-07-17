import SwiftUI

struct ModificaPiantaSheet: View {
    let pianta: PiantaColtivata
    let attivita: [Attivita]

    @Environment(SupabaseRepository.self) private var repository
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var lang

    @State private var valori: [String: Int]
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    private var attivitaUniche: [Attivita] {
        var seen = Set<String>()
        return attivita.filter { seen.insert($0.nome).inserted }
    }

    init(pianta: PiantaColtivata, attivita: [Attivita]) {
        self.pianta = pianta
        self.attivita = attivita
        var v: [String: Int] = [:]
        var seen = Set<String>()
        for att in attivita {
            guard seen.insert(att.nome).inserted else { continue }
            let override = pianta.activityOverrides?.first { $0.nome == att.nome }
            if att.recurrenceDays != nil {
                v[att.nome] = override?.recurrenceDays ?? att.recurrenceDays ?? 1
            } else {
                let firstDate = attivita.filter { $0.nome == att.nome }.map { $0.data }.min() ?? att.data
                let computed = Calendar.current.dateComponents([.day], from: pianta.dataSemina, to: firstDate).day ?? 0
                v[att.nome] = override?.offsetDays ?? max(computed, 0)
            }
        }
        _valori = State(initialValue: v)
    }

    var body: some View {
        NavigationStack {
            Form {
                if attivitaUniche.isEmpty {
                    Section {
                        Text(lang.plants.noScheduledActivities)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ForEach(attivitaUniche) { att in
                        Section(att.nome.capitalized) {
                            let binding = Binding(
                                get: { valori[att.nome] ?? 1 },
                                set: { valori[att.nome] = $0 }
                            )
                            if att.recurrenceDays != nil {
                                Stepper(String(format: lang.plants.everyNDaysFormat, valori[att.nome] ?? 1), value: binding, in: 1...365)
                            } else {
                                Stepper(String(format: lang.plants.afterNDaysFormat, valori[att.nome] ?? 0), value: binding, in: 0...730)
                            }
                        }
                    }
                }
            }
            .navigationTitle(lang.plants.editActivitiesNavTitle)
            .navigationBarTitleDisplayMode(.inline)
            .disabled(isLoading)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(lang.common.cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button(lang.common.save) { Task { await salva() } }
                            .fontWeight(.semibold)
                    }
                }
            }
            .alert(lang.common.error, isPresented: $showError) {
                Button(lang.common.ok, role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func salva() async {
        isLoading = true
        defer { isLoading = false }
        do {
            var overrides = pianta.activityOverrides ?? []
            for att in attivitaUniche {
                let valore = valori[att.nome] ?? (att.recurrenceDays ?? 1)
                overrides.removeAll { $0.nome == att.nome }
                if att.recurrenceDays != nil {
                    overrides.append(PiantaColtivata.ActivityOverride(nome: att.nome, recurrenceDays: valore, offsetDays: nil))
                } else {
                    overrides.append(PiantaColtivata.ActivityOverride(nome: att.nome, recurrenceDays: nil, offsetDays: valore))
                }
            }
            try await repository.updateActivityOverrides(piantaId: pianta.id, overrides: overrides)

            for att in attivitaUniche {
                let valore = valori[att.nome] ?? (att.recurrenceDays ?? 1)
                let attPerNome = attivita.filter { $0.nome == att.nome }
                let firstDate = attPerNome.map { $0.data }.min() ?? att.data
                let offsetDays = max(Calendar.current.dateComponents([.day], from: pianta.dataSemina, to: firstDate).day ?? 0, 0)
                let activity = SupabaseRepository.ScheduledTemplateActivity(
                    nome: att.nome,
                    offsetDays: att.recurrenceDays != nil ? offsetDays : valore,
                    recurrenceDays: att.recurrenceDays != nil ? valore : nil,
                    color: att.color
                )
                // Ornamentale: growthDays è 0 (nessun ciclo), usa lo stesso orizzonte
                // fisso adottato in AggiungiPiantaView per le cure ricorrenti.
                let scheduleHorizon = pianta.tipo == .raccolto ? pianta.growthDays : 365
                try await repository.rescheduleActivity(
                    piantaId: pianta.id,
                    dataSemina: pianta.dataSemina,
                    growthDays: scheduleHorizon,
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
