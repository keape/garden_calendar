import SwiftUI

struct MagazineView: View {
    @Environment(SupabaseRepository.self) private var repository
    @Environment(LanguageManager.self) private var lang

    @State private var catalogo: [PlantKnowledge] = []

    private var mese: Int { Calendar.current.component(.month, from: Date()) }

    private var articoli: [MagazineArticle] {
        MagazineGenerator.articoli(catalogo: catalogo, mese: mese)
    }

    private var nomeMese: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: lang.dayDetail.dateLocale)
        return f.standaloneMonthSymbols[mese - 1].capitalized
    }

    var body: some View {
        NavigationStack {
            Group {
                if articoli.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(format: lang.magazine.headerFormat, nomeMese))
                                .font(.dmSans(13, weight: .semibold))
                                .foregroundStyle(AppTheme.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)

                            LazyVStack(spacing: 10) {
                                ForEach(articoli) { articolo in
                                    NavigationLink {
                                        ArticleDetailView(articolo: articolo)
                                    } label: {
                                        MagazineArticleCard(articolo: articolo)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 16)
                    }
                }
            }
            .background(AppTheme.backgroundCream)
            .navigationTitle(lang.magazine.navTitle)
            .task { await loadCatalogo() }
            .refreshable { await loadCatalogo() }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(lang.magazine.emptyTitle, systemImage: "book")
        } description: {
            Text(lang.magazine.emptyDesc)
        }
    }

    private func loadCatalogo() async {
        catalogo = (try? await repository.fetchCatalogo()) ?? []
    }
}

// MARK: - Article Card

private struct MagazineArticleCard: View {
    @Environment(LanguageManager.self) private var lang
    let articolo: MagazineArticle

    private var badgeLabel: (PlantRelevance) -> String {
        { motivo in
            switch motivo {
            case .semina: return lang.magazine.seminaBadge
            case .raccolta: return lang.magazine.raccoltaBadge
            case .fioritura: return lang.magazine.fiorituraBadge
            }
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryGreen.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(emojiForPlant(articolo.pianta.specieNome))
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(articolo.pianta.specieNome)
                    .font(.dmSans(15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                HStack(spacing: 4) {
                    ForEach(articolo.motivi, id: \.self) { motivo in
                        Text(badgeLabel(motivo))
                            .font(.dmSans(10, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryGreen)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.primaryGreen.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }

                if let descrizione = articolo.pianta.descrizione {
                    Text(descrizione)
                        .font(.dmSans(12))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
    }
}

#Preview {
    MagazineView()
        .environment(SupabaseRepository.shared)
        .environment(LanguageManager.shared)
}
