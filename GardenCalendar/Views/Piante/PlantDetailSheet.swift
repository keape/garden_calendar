import SwiftUI

struct PlantDetailSheet: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.dismiss) private var dismiss
    @Environment(SupabaseRepository.self) private var repository

    let knowledge: PlantKnowledge
    let onAdd: ((PlantKnowledge) -> Void)?
    /// Orto di riferimento: se ha coordinate, semina/raccolta vengono ricalcolate sul suo clima locale.
    var orto: Orto? = nil

    @State private var normals: MonthlyClimateNormals?
    @State private var selectedCompanion: PlantKnowledge?

    /// Finestra semina/raccolta effettiva: calcolata sul clima dell'orto se disponibile, altrimenti baseline.
    private var window: SowingWindow {
        SowingCalculator.compute(for: knowledge, normals: normals)
    }

    private var monthAbbrs: [String] {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: lang.dayDetail.dateLocale)
        return fmt.veryShortStandaloneMonthSymbols
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    Divider().padding(.horizontal)
                    if !window.seminaEsterno.isEmpty || !window.seminaInterno.isEmpty
                        || !window.raccolta.isEmpty || !window.fioritura.isEmpty {
                        sowingSection
                        Divider().padding(.horizontal)
                    }
                    if knowledge.annaffiatura != nil || knowledge.esposizione != nil
                        || knowledge.phMin != nil || knowledge.tempTollMin != nil || knowledge.terriccio != nil {
                        careSection
                        Divider().padding(.horizontal)
                    }
                    if !knowledge.attivitaSuggerite.isEmpty {
                        activitiesSection
                        Divider().padding(.horizontal)
                    }
                    if !(knowledge.pianteCompagne ?? []).isEmpty || !(knowledge.pianteIncompatibili ?? []).isEmpty {
                        companionsSection
                        Divider().padding(.horizontal)
                    }
                    if let onAdd {
                        ctaSection(onAdd: onAdd)
                    }
                }
            }
            .background(AppTheme.backgroundCream)
            .navigationTitle(lang.plants.plantDetailTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
        .task {
            guard let lat = orto?.latitudine, let lon = orto?.longitudine else { return }
            normals = try? await ClimateNormalsClient.shared.fetchNormals(latitude: lat, longitude: lon)
        }
        .sheet(item: $selectedCompanion) { companion in
            PlantDetailSheet(knowledge: companion, onAdd: onAdd, orto: orto)
                .environment(repository)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let urlStr = knowledge.imageUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipped()
                    default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(knowledge.specieNome)
                    .font(.lora(22))
                    .foregroundStyle(AppTheme.textPrimary)

                if let sci = knowledge.specieNomeScentifico {
                    Text(sci)
                        .font(.dmSans(13))
                        .italic()
                        .foregroundStyle(AppTheme.textSecondary)
                }

                HStack(spacing: 6) {
                    if let tipo = knowledge.tipo {
                        badgeView(tipo.emoji + " " + tipo.displayName, color: AppTheme.primaryGreen)
                    }
                    if let diff = knowledge.difficolta {
                        badgeView(lang.plants.difficultyLabel + ": " + diff, color: difficultyColor(diff))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(AppTheme.cardSecondaryWarm)
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .overlay(
                Text(emojiForPlant(knowledge.specieNome))
                    .font(.system(size: 60))
            )
    }

    // MARK: - Sowing Calendar

    private var ganttRows: [(icon: String, label: String, months: [Int], color: Color)] {
        [
            ("🌍", lang.plants.seminaOutdoorLabel, window.seminaEsterno, AppTheme.primaryGreen),
            ("🏠", lang.plants.seminaIndoorLabel, window.seminaInterno, AppTheme.activityBlue),
            ("🧺", lang.plants.harvestMonthsLabel, window.raccolta, AppTheme.activityOrange),
            ("🌸", lang.plants.bloomMonthsLabel, window.fioritura, AppTheme.activityOrange),
        ].filter { !$0.months.isEmpty }
    }

    private var sowingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(lang.plants.seedingSection)
            VStack(alignment: .leading, spacing: 10) {
                ganttTimeline
                VStack(spacing: 6) {
                    ForEach(ganttRows, id: \.label) { row in
                        ganttBar(months: row.months, color: row.color)
                    }
                }
                VStack(spacing: 8) {
                    ForEach(ganttRows, id: \.label) { row in
                        legendRow(icon: row.icon, label: row.label, months: row.months, color: row.color)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }

    private var ganttTimeline: some View {
        HStack(spacing: 0) {
            ForEach(1...12, id: \.self) { m in
                Text(monthAbbrs[m - 1])
                    .font(.dmSans(9))
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.6))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func ganttBar(months: [Int], color: Color) -> some View {
        let start = months.min() ?? 1
        let end = months.max() ?? 1
        return GeometryReader { geo in
            let unit = geo.size.width / 12
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: unit * CGFloat(end - start + 1), height: 18)
                .offset(x: unit * CGFloat(start - 1))
        }
        .frame(height: 18)
    }

    private func legendRow(icon: String, label: String, months: [Int], color: Color) -> some View {
        let start = months.min() ?? 1
        let end = months.max() ?? 1
        return HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            Text("\(icon) \(label)")
                .font(.dmSans(12))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Text(start == end ? monthAbbrs[start - 1] : "\(monthAbbrs[start - 1]) – \(monthAbbrs[end - 1])")
                .font(.dmSans(12, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }

    // MARK: - Care

    private var careSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(lang.plants.careSection)
            VStack(alignment: .leading, spacing: 8) {
                if let w = knowledge.annaffiatura {
                    careRow(icon: "drop.fill", label: lang.plants.wateringLabel, value: w, color: AppTheme.activityBlue)
                }
                if let e = knowledge.esposizione {
                    careRow(icon: "sun.max.fill", label: lang.plants.exposureLabel, value: e, color: AppTheme.accentAmbra)
                }
                if let phMin = knowledge.phMin, let phMax = knowledge.phMax {
                    careRow(icon: "eyedropper.halffull", label: lang.plants.phLabel, value: String(format: "%.1f – %.1f", phMin, phMax), color: AppTheme.primaryGreen)
                }
                if let t = knowledge.tempTollMin {
                    careRow(icon: "thermometer.snowflake", label: lang.plants.toleranceTempLabel, value: String(format: "%.0f°C", t), color: AppTheme.activityBlue)
                }
                if let s = knowledge.terriccio {
                    careRow(icon: "square.3.layers.3d.down.right", label: lang.plants.soilLabel, value: s, color: AppTheme.accentAmbra)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }

    private func careRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.dmSans(11))
                    .foregroundStyle(AppTheme.textSecondary)
                Text(value)
                    .font(.dmSans(14, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
    }

    // MARK: - Activities

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(lang.plants.detailActivitiesSection)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(knowledge.attivitaSuggerite, id: \.nome) { att in
                        activityBadge(att)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
    }

    private func activityBadge(_ att: PlantKnowledge.AttivitaSuggerita) -> some View {
        let color = AppTheme.colorForActivity(att.nome)
        return VStack(alignment: .leading, spacing: 3) {
            Text(att.nome)
                .font(.dmSans(12, weight: .semibold))
                .foregroundStyle(color)
            if let r = att.recurrenceDays {
                Text(String(format: lang.plants.everyNDaysShortFormat, r))
                    .font(.dmSans(10))
                    .foregroundStyle(AppTheme.textSecondary)
            } else if att.offsetDays > 0 {
                Text(String(format: lang.plants.afterNDaysShortFormat, att.offsetDays))
                    .font(.dmSans(10))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Companions

    private var companionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(lang.plants.companionsSection)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(knowledge.pianteCompagne ?? [], id: \.self) { p in
                        chipView(p, color: AppTheme.primaryGreen)
                    }
                    ForEach(knowledge.pianteIncompatibili ?? [], id: \.self) { p in
                        chipView(p, color: AppTheme.activityRed)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
    }

    private func chipView(_ text: String, color: Color) -> some View {
        Button {
            Task { await openCompanion(named: text) }
        } label: {
            Text(text)
                .font(.dmSans(12, weight: .medium))
                .foregroundStyle(color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(color.opacity(0.10))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func openCompanion(named name: String) async {
        let results = (try? await repository.searchCatalogo(query: name)) ?? []
        selectedCompanion = results.first {
            $0.specieNome.localizedCaseInsensitiveCompare(name) == .orderedSame
        } ?? results.first
    }

    // MARK: - CTA

    private func ctaSection(onAdd: @escaping (PlantKnowledge) -> Void) -> some View {
        Button {
            onAdd(knowledge)
            dismiss()
        } label: {
            Text(lang.plants.addToGardenButton)
                .font(.dmSans(16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.ctaDarkGreen)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.dmSans(13, weight: .semibold))
            .foregroundStyle(AppTheme.textSecondary)
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 4)
    }

    private func badgeView(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.dmSans(11, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private func difficultyColor(_ d: String) -> Color {
        switch d.lowercased() {
        case "facile": return AppTheme.primaryGreen
        case "difficile": return AppTheme.activityRed
        default: return AppTheme.activityOrange
        }
    }
}
