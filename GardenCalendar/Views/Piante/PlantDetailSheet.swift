import SwiftUI

struct PlantDetailSheet: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.dismiss) private var dismiss

    let knowledge: PlantKnowledge
    let onAdd: ((PlantKnowledge) -> Void)?

    private let monthAbbrs: [String] = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "it_IT")
        return fmt.veryShortStandaloneMonthSymbols
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    Divider().padding(.horizontal)
                    if !knowledge.seminaMesiEsterno.isEmpty || !knowledge.seminaMesiInterno.isEmpty {
                        sowingSection
                        Divider().padding(.horizontal)
                    }
                    if knowledge.annaffiatura != nil || knowledge.esposizione != nil || knowledge.mesiRaccolta != nil {
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
                        badgeView(diff, color: difficultyColor(diff))
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

    private var sowingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(lang.plants.seedingSection)
            VStack(alignment: .leading, spacing: 6) {
                monthRow(label: "🌍", months: knowledge.seminaMesiEsterno, color: AppTheme.primaryGreen)
                monthRow(label: "🏠", months: knowledge.seminaMesiInterno, color: AppTheme.activityBlue)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }

    private func monthRow(label: String, months: [Int], color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label).font(.system(size: 14))
            ForEach(1...12, id: \.self) { m in
                let active = months.contains(m)
                Text(monthAbbrs[m - 1])
                    .font(.dmSans(9, weight: active ? .semibold : .regular))
                    .foregroundStyle(active ? .white : AppTheme.textSecondary.opacity(0.5))
                    .frame(width: 22, height: 22)
                    .background(active ? color : color.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
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
                if let m = knowledge.mesiRaccolta, !m.isEmpty {
                    careRow(icon: "basket.fill", label: lang.plants.harvestMonthsLabel, value: monthNamesShort(m), color: AppTheme.activityOrange)
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
                Text("ogni \(r)gg")
                    .font(.dmSans(10))
                    .foregroundStyle(AppTheme.textSecondary)
            } else if att.offsetDays > 0 {
                Text("dopo \(att.offsetDays)gg")
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
        Text(text)
            .font(.dmSans(12, weight: .medium))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.10))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
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

    private func monthNamesShort(_ months: [Int]) -> String {
        months.sorted().compactMap { m -> String? in
            guard (1...12).contains(m) else { return nil }
            return monthAbbrs[m - 1]
        }.joined(separator: ", ")
    }
}
