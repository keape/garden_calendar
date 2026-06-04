import SwiftUI

struct NuovaAttivitaSheet: View {
    let pianta: PiantaColtivata

    @Environment(SupabaseRepository.self) private var repository
    @Environment(\.dismiss) private var dismiss

    @State private var nome = ""
    @State private var isRicorrente = true
    @State private var valore = 7
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Dettagli attività") {
                    TextField("Es. irrigazione, concimazione…", text: $nome)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)

                    Picker("Tipo", selection: $isRicorrente) {
                        Text("Ricorrente").tag(true)
                        Text("Una tantum").tag(false)
                    }
                }

                Section {
                    if isRicorrente {
                        Stepper("Ogni \(valore) giorni", value: $valore, in: 1...365)
                    } else {
                        Stepper("Dopo \(valore) giorni dalla semina", value: $valore, in: 0...730)
                    }
                } header: {
                    Text("Intervallo")
                }
            }
            .navigationTitle("Nuova attività")
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
                        Button("Aggiungi") {
                            Task { await aggiungi() }
                        }
                        .fontWeight(.semibold)
                        .disabled(nome.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .alert("Errore", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func aggiungi() async {
        let nomeClean = nome.trimmingCharacters(in: .whitespaces).lowercased()
        guard !nomeClean.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            var overrides = pianta.activityOverrides ?? []
            overrides.removeAll { $0.nome == nomeClean }
            if isRicorrente {
                overrides.append(PiantaColtivata.ActivityOverride(
                    nome: nomeClean, recurrenceDays: valore, offsetDays: nil
                ))
            } else {
                overrides.append(PiantaColtivata.ActivityOverride(
                    nome: nomeClean, recurrenceDays: nil, offsetDays: valore
                ))
            }
            try await repository.updateActivityOverrides(piantaId: pianta.id, overrides: overrides)

            let activity = SupabaseRepository.ScheduledTemplateActivity(
                nome: nomeClean,
                offsetDays: isRicorrente ? 0 : valore,
                recurrenceDays: isRicorrente ? valore : nil,
                color: ""
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
}
