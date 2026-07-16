import Foundation

enum PlantRelevance: CaseIterable, Hashable {
    case semina, raccolta, fioritura
}

struct MagazineArticle: Identifiable {
    let id: String
    let pianta: PlantKnowledge
    let mese: Int
    let motivi: [PlantRelevance]
}

enum MagazineGenerator {
    /// Genera al massimo 5 articoli per il mese dato, ordinati per slug (deterministico).
    static func articoli(catalogo: [PlantKnowledge], mese: Int) -> [MagazineArticle] {
        catalogo
            .compactMap { pk -> MagazineArticle? in
                var motivi: [PlantRelevance] = []
                if pk.seminaMesiEsterno.contains(mese) || pk.seminaMesiInterno.contains(mese) {
                    motivi.append(.semina)
                }
                if pk.mesiRaccolta?.contains(mese) == true {
                    motivi.append(.raccolta)
                }
                if pk.mesiFioritura?.contains(mese) == true {
                    motivi.append(.fioritura)
                }
                guard !motivi.isEmpty else { return nil }
                return MagazineArticle(id: pk.slug, pianta: pk, mese: mese, motivi: motivi)
            }
            .sorted { $0.id < $1.id }
            .prefix(5)
            .map { $0 }
    }
}
