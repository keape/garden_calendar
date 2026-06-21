import Foundation

enum PlantType: String, Codable, CaseIterable, Sendable {
    case ortaggio, aromatica, frutto, fiore, altro

    var displayName: String {
        switch self {
        case .ortaggio: return "Ortaggio"
        case .aromatica: return "Aromatica"
        case .frutto: return "Frutto"
        case .fiore: return "Fiore"
        case .altro: return "Altro"
        }
    }

    var emoji: String {
        switch self {
        case .ortaggio: return "🥦"
        case .aromatica: return "🌿"
        case .frutto: return "🍓"
        case .fiore: return "🌸"
        case .altro: return "🌱"
        }
    }
}

struct PlantKnowledge: Codable, Identifiable, Sendable {
    let id: UUID
    let slug: String
    let specieNome: String
    let growthDays: Int
    let attivitaSuggerite: [AttivitaSuggerita]
    let seminaMesiEsterno: [Int]
    let seminaMesiInterno: [Int]
    let createdAt: Date
    let updatedAt: Date

    // Campi arricchiti (opzionali — piante legacy li hanno nil)
    let specieNomeScentifico: String?
    let descrizione: String?
    let annaffiatura: String?
    let esposizione: String?
    let tipo: PlantType?
    let difficolta: String?
    let imageUrl: String?
    let mesiRaccolta: [Int]?
    let pianteCompagne: [String]?
    let pianteIncompatibili: [String]?

    enum CodingKeys: String, CodingKey {
        case id, slug
        case specieNome = "specie_nome"
        case growthDays = "growth_days"
        case attivitaSuggerite = "attivita_suggerite"
        case seminaMesiEsterno = "semina_mesi_esterno"
        case seminaMesiInterno = "semina_mesi_interno"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case specieNomeScentifico = "specie_nome_scientifico"
        case descrizione
        case annaffiatura
        case esposizione
        case tipo
        case difficolta
        case imageUrl = "image_url"
        case mesiRaccolta = "mesi_raccolta"
        case pianteCompagne = "piante_compagne"
        case pianteIncompatibili = "piante_incompatibili"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        slug = try c.decode(String.self, forKey: .slug)
        specieNome = try c.decode(String.self, forKey: .specieNome)
        growthDays = try c.decode(Int.self, forKey: .growthDays)

        // attivita_suggerite è JSONB in PostgreSQL → array diretto
        // Se PostgREST restituisce una stringa JSON (comportamento legacy),
        // proviamo prima come array, poi come stringa da ri-parsare.
        if let arr = try? c.decode([AttivitaSuggerita].self, forKey: .attivitaSuggerite) {
            attivitaSuggerite = arr
        } else if let raw = try? c.decode(String.self, forKey: .attivitaSuggerite),
                  let data = raw.data(using: .utf8),
                  let parsed = try? JSONDecoder().decode([AttivitaSuggerita].self, from: data) {
            attivitaSuggerite = parsed
        } else {
            attivitaSuggerite = []
        }

        seminaMesiEsterno = (try? c.decodeIfPresent([Int].self, forKey: .seminaMesiEsterno)) ?? []
        seminaMesiInterno = (try? c.decodeIfPresent([Int].self, forKey: .seminaMesiInterno)) ?? []
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)

        specieNomeScentifico = try? c.decodeIfPresent(String.self, forKey: .specieNomeScentifico)
        descrizione = try? c.decodeIfPresent(String.self, forKey: .descrizione)
        annaffiatura = try? c.decodeIfPresent(String.self, forKey: .annaffiatura)
        esposizione = try? c.decodeIfPresent(String.self, forKey: .esposizione)
        tipo = try? c.decodeIfPresent(PlantType.self, forKey: .tipo)
        difficolta = try? c.decodeIfPresent(String.self, forKey: .difficolta)
        imageUrl = try? c.decodeIfPresent(String.self, forKey: .imageUrl)
        mesiRaccolta = try? c.decodeIfPresent([Int].self, forKey: .mesiRaccolta)
        pianteCompagne = try? c.decodeIfPresent([String].self, forKey: .pianteCompagne)
        pianteIncompatibili = try? c.decodeIfPresent([String].self, forKey: .pianteIncompatibili)
    }
}

extension PlantKnowledge {
    struct AttivitaSuggerita: Codable, Sendable {
        let nome: String
        let offsetDays: Int
        let recurrenceDays: Int?
        let color: String

        enum CodingKeys: String, CodingKey {
            case nome
            case offsetDays = "offset_days"
            case recurrenceDays = "recurrence_days"
            case color
        }
    }
}
