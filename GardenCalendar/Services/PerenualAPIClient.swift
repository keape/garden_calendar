import Foundation

struct PerenualAPIClient: Sendable {
    private let apiKey: String
    private let baseURL = "https://perenual.com/api"

    init(apiKey: String = SupabaseConfig.perenualApiKey) {
        self.apiKey = apiKey
    }

    func search(_ query: String) async throws -> [PlantKnowledge] {
        guard !apiKey.hasPrefix("INSERIRE") else { return [] }
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "\(baseURL)/species-list?key=\(apiKey)&q=\(encoded)&page=1")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { return [] }
        let result = try JSONDecoder().decode(PerenualSearchResponse.self, from: data)
        return result.data.compactMap { toPlantKnowledge($0) }
    }

    private func toPlantKnowledge(_ p: PerenualPlant) -> PlantKnowledge? {
        guard let name = p.commonName, !name.isEmpty else { return nil }
        let slug = "perenual-\(p.id)"
        // Placeholder UUID per piante esterne — non persistono in Supabase
        let id = UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012d", p.id % 1_000_000_000_000))") ?? UUID()

        let annaffiatura: String? = switch p.watering {
            case "Frequent": "ogni 2-3 giorni"
            case "Average": "ogni 4-5 giorni"
            case "Minimum": "ogni 7-10 giorni"
            case "None": "raramente, solo in siccità"
            default: nil
        }

        let esposizione: String? = p.sunlight?.first.map { sun in
            switch sun.lowercased() {
            case let s where s.contains("full sun"): return "Pieno sole"
            case let s where s.contains("part shade"): return "Mezza ombra"
            case let s where s.contains("full shade"): return "Ombra"
            default: return sun.capitalized
            }
        }

        let imageUrl = p.defaultImage?.mediumUrl

        // Usa attività di default categoria (non abbiamo dati Perenual specifici)
        let attivita: [PlantKnowledge.AttivitaSuggerita] = [
            .init(nome: "Irrigazione", offsetDays: 0, recurrenceDays: 4, color: "blue"),
            .init(nome: "Raccolta", offsetDays: 90, recurrenceDays: nil, color: "orange")
        ]

        return PlantKnowledge(
            id: id,
            slug: slug,
            specieNome: name,
            growthDays: 90,
            attivitaSuggerite: attivita,
            seminaMesiEsterno: [],
            seminaMesiInterno: [],
            createdAt: Date(),
            updatedAt: Date(),
            specieNomeScentifico: p.scientificName?.first,
            descrizione: nil,
            annaffiatura: annaffiatura,
            esposizione: esposizione,
            tipo: nil,
            difficolta: nil,
            imageUrl: imageUrl,
            mesiRaccolta: nil,
            pianteCompagne: nil,
            pianteIncompatibili: nil
        )
    }
}

// MARK: - Perenual Response Models

private struct PerenualSearchResponse: Decodable {
    let data: [PerenualPlant]
}

private struct PerenualPlant: Decodable {
    let id: Int
    let commonName: String?
    let scientificName: [String]?
    let watering: String?
    let sunlight: [String]?
    let defaultImage: PerenualImage?

    enum CodingKeys: String, CodingKey {
        case id
        case commonName = "common_name"
        case scientificName = "scientific_name"
        case watering
        case sunlight
        case defaultImage = "default_image"
    }
}

private struct PerenualImage: Decodable {
    let mediumUrl: String?
    enum CodingKeys: String, CodingKey { case mediumUrl = "medium_url" }
}
