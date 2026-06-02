import SwiftUI


struct AggiungiPiantaView: View {
    @Environment(SupabaseRepository.self) private var repository
    @Environment(\.dismiss) private var dismiss

    let ortoId: UUID?

    @State private var searchText = ""
    @State private var selectedFromCatalog: String? = nil
    @State private var isSearching = false

    @State private var customName = ""
    @State private var customGrowthDays = 90
    @State private var customSeminaDate = Date()

    @State private var importedActivities: [TemplateActivity] = []

    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false

    init(ortoId: UUID? = nil) {
        self.ortoId = ortoId
    }

    private let catalogSuggestions = [
        "Pomodoro", "Basilico", "Lattuga", "Zucchina", "Melanzana",
        "Peperone", "Rosmarino", "Menta", "Prezzemolo", "Salvia",
        "Fragola", "Carota", "Cipolla", "Aglio", "Spinacio",
        "Rucola", "Cetriolo", "Fagiolo", "Pisello", "Girasole"
    ]

    private var filteredCatalog: [String] {
        if searchText.isEmpty { return Array(catalogSuggestions.prefix(10)) }
        return catalogSuggestions.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Cerca nel catalogo...", text: $searchText)
                        .autocorrectionDisabled()
                        .onChange(of: searchText) { _, newValue in
                            if !newValue.isEmpty {
                                selectedFromCatalog = nil
                                importedActivities = []
                            }
                        }
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(AppTheme.cardSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()

                if isSearching {
                    ProgressView("Ricerca in corso...")
                        .padding()
                }

                if !filteredCatalog.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dal catalogo")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(filteredCatalog, id: \.self) { nome in
                                    Button(action: {
                                        selectFromCatalog(nome)
                                    }) {
                                        HStack {
                                            Image(systemName: "leaf.fill")
                                                .foregroundStyle(AppTheme.primaryGreen)
                                            Text(nome)
                                                .foregroundStyle(.primary)
                                            Spacer()
                                            if selectedFromCatalog == nome {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(AppTheme.primaryGreen)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 10)
                                    }

                                    if nome != filteredCatalog.last {
                                        Divider().padding(.leading)
                                    }
                                }
                            }
                        }
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                }

                if selectedFromCatalog == nil {
                    Divider()
                        .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pianta personalizzata")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        VStack(spacing: 0) {
                            Form {
                                TextField("Nome pianta", text: $customName)
                                    .autocorrectionDisabled()

                                Stepper("Ciclo crescita: \(customGrowthDays) giorni", value: $customGrowthDays, in: 1...730)

                                DatePicker("Data semina", selection: $customSeminaDate, displayedComponents: .date)
                            }
                            .scrollDisabled(true)
                            .frame(height: 200)
                        }
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                }

                if !importedActivities.isEmpty {
                    Divider()
                        .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Attività importate dal catalogo")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        ForEach(importedActivities, id: \.name) { activity in
                            HStack {
                                ActivityColorDot(activityName: activity.name, size: 8)
                                Text(activity.name)
                                    .font(.subheadline)
                                Spacer()
                                Text("g\(activity.offsetDays)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if let rec = activity.recurrenceDays {
                                    Text("ogni \(rec)g")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Aggiungi pianta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Salva", action: savePianta)
                            .fontWeight(.semibold)
                            .disabled(!canSave)
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertMessage.contains("successo") ? "Salvato" : "Errore"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertMessage.contains("successo") {
                            dismiss()
                        }
                    }
                )
            }
        }
    }

    private var canSave: Bool {
        if let selected = selectedFromCatalog {
            return !selected.isEmpty
        }
        return !customName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func selectFromCatalog(_ nome: String) {
        selectedFromCatalog = nome
        customName = nome
        importedActivities = generateTemplateActivities(for: nome)
    }

    private func generateTemplateActivities(for plant: String) -> [TemplateActivity] {
        switch plant.lowercased() {
        case "pomodoro":
            return [
                TemplateActivity(name: "Semina", offsetDays: 0),
                TemplateActivity(name: "Trapianto", offsetDays: 45),
                TemplateActivity(name: "Irrigazione", offsetDays: 0, recurrenceDays: 3),
                TemplateActivity(name: "Concimazione", offsetDays: 30, recurrenceDays: 20),
                TemplateActivity(name: "Raccolta", offsetDays: 80),
            ]
        case "basilico":
            return [
                TemplateActivity(name: "Semina", offsetDays: 0),
                TemplateActivity(name: "Irrigazione", offsetDays: 0, recurrenceDays: 2),
                TemplateActivity(name: "Raccolta", offsetDays: 30),
            ]
        default:
            return [
                TemplateActivity(name: "Semina", offsetDays: 0),
                TemplateActivity(name: "Irrigazione", offsetDays: 0, recurrenceDays: 3),
                TemplateActivity(name: "Raccolta", offsetDays: customGrowthDays),
            ]
        }
    }

    private func savePianta() {
        guard let ortoId else {
            alertMessage = "Impossibile salvare: apri questa schermata da un orto specifico."
            showAlert = true
            return
        }

        let nome: String
        if let selected = selectedFromCatalog {
            nome = selected
        } else {
            nome = customName.trimmingCharacters(in: .whitespaces)
        }

        guard !nome.isEmpty else {
            alertMessage = "Inserisci un nome per la pianta."
            showAlert = true
            return
        }

        let seminaDate = Calendar.current.startOfDay(for: customSeminaDate)

        isSaving = true
        Task {
            do {
                let nuovaPianta = try await repository.createPianta(pianta: PiantaColtivata.Create(
                    ortoId: ortoId,
                    specieId: nil,
                    nomePersonalizzato: nome,
                    dataSemina: seminaDate,
                    growthDays: customGrowthDays,
                    note: nil,
                    fotoUrl: nil
                ))

                if !importedActivities.isEmpty {
                    let scheduled = importedActivities.map {
                        SupabaseRepository.ScheduledTemplateActivity(
                            nome: $0.name,
                            offsetDays: $0.offsetDays,
                            recurrenceDays: $0.recurrenceDays,
                            color: colorString(for: $0.name)
                        )
                    }
                    _ = try await repository.scheduleActivities(
                        piantaId: nuovaPianta.id,
                        dataSemina: seminaDate,
                        growthDays: customGrowthDays,
                        activities: scheduled
                    )
                }

                alertMessage = "\(nome) aggiunta con successo!"
                showAlert = true
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
            isSaving = false
        }
    }

    private func colorString(for activity: String) -> String {
        let lower = activity.lowercased()
        if lower.contains("irrigaz") || lower.contains("acqua") { return "blue" }
        if lower.contains("raccolt") { return "orange" }
        if lower.contains("semina") || lower.contains("trapianto") { return "green" }
        if lower.contains("concim") || lower.contains("trattam") { return "red" }
        return "purple"
    }
}

// MARK: - Template Activity

struct TemplateActivity {
    let name: String
    let offsetDays: Int
    var recurrenceDays: Int?
}

#Preview {
    AggiungiPiantaView()
        .environment(SupabaseRepository.shared)
}
