import SwiftUI

struct AggiungiPiantaView: View {
    @Environment(SupabaseRepository.self) private var repository
    @Environment(PlantCatalogService.self) private var catalogService
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var lang

    let ortoId: UUID?
    /// Orto completo (con coordinate), per calcolare semina/raccolta locali nella scheda pianta.
    var orto: Orto? = nil

    @State private var searchText = ""
    @State private var detailKnowledge: PlantKnowledge? = nil

    @State private var customName = ""
    @State private var customGrowthDays = 90
    @State private var customSeminaDate = Date()
    @State private var importedActivities: [TemplateActivity] = []

    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertIsSuccess = false
    @State private var isSaving = false

    init(ortoId: UUID? = nil, orto: Orto? = nil) {
        self.ortoId = ortoId
        self.orto = orto
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    searchBar
                        .padding()

                    if catalogService.isSearchingExternal {
                        ProgressView(lang.plants.searchingLabel)
                            .padding()
                    }

                    if !catalogService.localResults.isEmpty {
                        catalogSection(
                            title: lang.plants.catalogSection,
                            results: catalogService.localResults,
                            isExternal: false
                        )
                    }

                    if !catalogService.externalResults.isEmpty {
                        catalogSection(
                            title: lang.plants.onlineCatalogSection,
                            results: catalogService.externalResults,
                            isExternal: true
                        )
                    }

                    Divider().padding(.vertical, 8)

                    manualSection
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(lang.plants.addPlantNavTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(lang.common.cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button(lang.common.save, action: savePianta)
                            .fontWeight(.semibold)
                            .disabled(!canSave)
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertIsSuccess ? lang.plants.savedTitle : lang.common.error),
                    message: Text(alertMessage),
                    dismissButton: .default(Text(lang.common.ok)) {
                        if alertIsSuccess { dismiss() }
                    }
                )
            }
            .sheet(item: $detailKnowledge) { knowledge in
                PlantDetailSheet(knowledge: knowledge, onAdd: { k in
                    addFromKnowledge(k)
                }, orto: orto)
                .environment(lang)
            }
            .task(id: searchText) {
                let trimmed = searchText.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                await catalogService.search(query: trimmed, in: repository)
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(lang.plants.catalogSearchPlaceholder, text: $searchText)
                .autocorrectionDisabled()
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
    }

    // MARK: - Catalog Section

    private func catalogSection(title: String, results: [PlantKnowledge], isExternal: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                if isExternal {
                    Text(lang.plants.partialDataBadge)
                        .font(.dmSans(10, weight: .semibold))
                        .foregroundStyle(AppTheme.activityOrange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.activityOrange.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)

            LazyVStack(spacing: 0) {
                ForEach(results) { knowledge in
                    Button {
                        detailKnowledge = knowledge
                    } label: {
                        HStack {
                            Text(emojiForPlant(knowledge.specieNome))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(knowledge.specieNome)
                                    .foregroundStyle(.primary)
                                if let sci = knowledge.specieNomeScentifico {
                                    Text(sci)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .italic()
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    if knowledge.id != results.last?.id {
                        Divider().padding(.leading)
                    }
                }
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Manual Section

    private var manualSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(lang.plants.customPlantSection)
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            VStack(spacing: 0) {
                Form {
                    TextField(lang.plants.plantNamePlaceholder, text: $customName)
                        .autocorrectionDisabled()
                    Stepper(String(format: lang.plants.growthCycleFormat, customGrowthDays), value: $customGrowthDays, in: 1...730)
                    DatePicker(lang.plants.seedingDateLabel, selection: $customSeminaDate, displayedComponents: .date)
                }
                .scrollDisabled(true)
                .frame(height: 200)
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            if !importedActivities.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(lang.plants.importedActivitiesSection)
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    ForEach(importedActivities, id: \.name) { activity in
                        HStack {
                            ActivityColorDot(activityName: activity.name, size: 8)
                            Text(activity.name)
                                .font(.subheadline)
                            Spacer()
                            if let rec = activity.recurrenceDays {
                                Text(String(format: lang.plants.everyNDaysShortFormat, rec))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else if activity.offsetDays > 0 {
                                Text(String(format: lang.plants.afterNDaysShortFormat, activity.offsetDays))
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
    }

    // MARK: - Actions

    private var canSave: Bool {
        !customName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func addFromKnowledge(_ knowledge: PlantKnowledge) {
        customName = knowledge.specieNome
        customGrowthDays = knowledge.growthDays
        importedActivities = knowledge.attivitaSuggerite.map {
            TemplateActivity(name: $0.nome, offsetDays: $0.offsetDays, recurrenceDays: $0.recurrenceDays)
        }
        savePianta()
    }

    private func savePianta() {
        guard let ortoId else {
            alertIsSuccess = false
            alertMessage = lang.plants.cannotSaveNoOrto
            showAlert = true
            return
        }

        let nome = customName.trimmingCharacters(in: .whitespaces)
        guard !nome.isEmpty else {
            alertIsSuccess = false
            alertMessage = lang.plants.enterPlantName
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

                alertIsSuccess = true
                alertMessage = String(format: lang.plants.addedSuccessFormat, nome)
                showAlert = true
            } catch {
                alertIsSuccess = false
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
        .environment(LanguageManager.shared)
        .environment(PlantCatalogService.shared)
}
