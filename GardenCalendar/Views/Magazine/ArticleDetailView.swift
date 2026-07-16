import SwiftUI

struct ArticleDetailView: View {
    @Environment(LanguageManager.self) private var lang

    let articolo: MagazineArticle

    private var pianta: PlantKnowledge { articolo.pianta }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                Divider().padding(.horizontal)
                whySection
                Divider().padding(.horizontal)
                if let descrizione = pianta.descrizione {
                    descriptionSection(descrizione)
                    Divider().padding(.horizontal)
                }
                if pianta.annaffiatura != nil || pianta.esposizione != nil {
                    careSection
                    Divider().padding(.horizontal)
                }
                if !pianta.attivitaSuggerite.isEmpty {
                    activitiesSection
                    Divider().padding(.horizontal)
                }
                if !(pianta.pianteCompagne ?? []).isEmpty || !(pianta.pianteIncompatibili ?? []).isEmpty {
                    companionsSection
                }
            }
        }
        .background(AppTheme.backgroundCream)
        .navigationTitle(pianta.specieNome)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(pianta.specieNome)
                .font(.lora(22))
                .foregroundStyle(AppTheme.textPrimary)

            if let sci = pianta.specieNomeScentifico {
                Text(sci)
                    .font(.dmSans(13))
                    .italic()
                    .foregroundStyle(AppTheme.textSecondary)
            }

            HStack(spacing: 6) {
                if let tipo = pianta.tipo {
                    badgeView(tipo.emoji + " " + tipo.displayName, color: AppTheme.primaryGreen)
                }
                if let diff = pianta.difficolta {
                    badgeView(diff, color: AppTheme.activityOrange)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
    }

    // MARK: - Why this month

    private var whySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(lang.magazine.whySection)
            HStack(spacing: 6) {
                ForEach(articolo.motivi, id: \.self) { motivo in
                    badgeView(motivoLabel(motivo), color: AppTheme.primaryGreen)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }

    private func motivoLabel(_ motivo: PlantRelevance) -> String {
        switch motivo {
        case .semina: return lang.magazine.seminaBadge
        case .raccolta: return lang.magazine.raccoltaBadge
        case .fioritura: return lang.magazine.fiorituraBadge
        }
    }

    // MARK: - Description

    private func descriptionSection(_ testo: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(lang.magazine.descriptionSection)
            Text(testo)
                .font(.dmSans(14))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal)
                .padding(.bottom, 16)
        }
    }

    // MARK: - Care

    private var careSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(lang.magazine.careSection)
            VStack(alignment: .leading, spacing: 8) {
                if let w = pianta.annaffiatura {
                    careRow(icon: "drop.fill", label: lang.plants.wateringLabel, value: w, color: AppTheme.activityBlue)
                }
                if let e = pianta.esposizione {
                    careRow(icon: "sun.max.fill", label: lang.plants.exposureLabel, value: e, color: AppTheme.accentAmbra)
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
            sectionHeader(lang.magazine.activitiesSection)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(pianta.attivitaSuggerite, id: \.nome) { att in
                        Text(att.nome)
                            .font(.dmSans(12, weight: .semibold))
                            .foregroundStyle(AppTheme.colorForActivity(att.nome))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(AppTheme.colorForActivity(att.nome).opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
    }

    // MARK: - Companions

    private var companionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(lang.magazine.companionsSection)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(pianta.pianteCompagne ?? [], id: \.self) { p in
                        chipView(p, color: AppTheme.primaryGreen)
                    }
                    ForEach(pianta.pianteIncompatibili ?? [], id: \.self) { p in
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
}
