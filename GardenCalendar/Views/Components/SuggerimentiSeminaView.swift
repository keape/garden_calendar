import SwiftUI

/// Suggerimenti di semina per il mese corrente, in base alla posizione del giardino.
/// - Emisfero: dalla latitudine dell'orto rappresentativo (lat < 0 → sud → sfasamento di 6 mesi).
/// - Interno/esterno: usa `semina_mesi_interno` per i giardini interni, altrimenti `semina_mesi_esterno`.
struct SuggerimentiSeminaView: View {
    @Environment(LanguageManager.self) private var lang

    let catalogo: [PlantKnowledge]
    let orti: [Orto]
    let filterOrtoId: UUID?

    @State private var normals: MonthlyClimateNormals?

    /// Orto su cui basare i consigli: quello filtrato, altrimenti il primo disponibile.
    private var ortoRiferimento: Orto? {
        orti.first(where: { $0.id == filterOrtoId }) ?? orti.first
    }

    private var interno: Bool { ortoRiferimento?.interno ?? false }

    /// Mese corrente (1-12) corretto per l'emisfero (usato solo nel fallback senza normali climatiche).
    private var meseEffettivo: Int {
        let mese = Calendar.current.component(.month, from: Date())
        let lat = ortoRiferimento?.latitudine ?? 45
        guard lat < 0 else { return mese }
        return ((mese - 1 + 6) % 12) + 1
    }

    private var suggerimenti: [PlantKnowledge] {
        catalogo.filter { pk in
            let window = SowingCalculator.compute(for: pk, normals: normals)
            let mesi = interno ? window.seminaInterno : window.seminaEsterno
            // Con normali climatiche il mese corrente non necessita correzione emisfero (già nel calcolo).
            let mese = normals != nil ? Calendar.current.component(.month, from: Date()) : meseEffettivo
            return mesi.contains(mese)
        }
    }

    private var titolo: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: lang.language == .it ? "it_IT" : "en_US")
        let nomeMese = f.standaloneMonthSymbols[Calendar.current.component(.month, from: Date()) - 1]
        return String(format: lang.calendar.seminaSectionTitleFormat, nomeMese.capitalized)
    }

    var body: some View {
        Group {
            if !suggerimenti.isEmpty {
                content
            }
        }
        .task(id: ortoRiferimento?.id) {
            guard let lat = ortoRiferimento?.latitudine, let lon = ortoRiferimento?.longitudine else {
                normals = nil
                return
            }
            normals = try? await ClimateNormalsClient.shared.fetchNormals(latitude: lat, longitude: lon)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(titolo)
                    .font(.dmSans(13, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                if interno {
                    Text(lang.calendar.seminaIndoorBadge)
                        .font(.dmSans(10, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryGreen)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.primaryGreen.opacity(0.12))
                        .clipShape(Capsule())
                }
                Spacer()
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggerimenti) { pk in
                        HStack(spacing: 5) {
                            Text(emojiForPlant(pk.specieNome))
                                .font(.system(size: 16))
                            Text(pk.specieNome)
                                .font(.dmSans(12, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.cardBackground)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(AppTheme.cardSecondaryWarm)
    }
}
