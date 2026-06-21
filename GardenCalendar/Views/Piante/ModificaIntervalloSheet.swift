import SwiftUI

struct ModificaIntervalloSheet: View {
    let pianta: PiantaColtivata
    let attivita: Attivita
    let tutteAttivita: [Attivita]

    @Environment(SupabaseRepository.self) private var repository
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var lang

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
                        Stepper(String(format: lang.plants.everyNDaysFormat, valore), value: $valore, in: 1...365)
                    } else {
                        Stepper(String(format: lang.plants.afterNDaysFormat, valore), value: $valore, in: 0...730)
                    }
                } header: {
                    Text(attivita.nome.capitalized)
                }

                Section {
                    Button(lang.plants.restoreDefault, role: .destructive) {
                        Task { await ripristinaDefault() }
                    }
                    .disabled(pianta.specieId == nil)
                }
            }
            .navigationTitle(lang.plants.editIntervalNavTitle)
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
                        Button(lang.common.save) {
                            Task { await salva() }
                        }
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
            if let def = knowledge.attivitaSuggerite.first(where: { $0.nome == attivita.nome }) {
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
