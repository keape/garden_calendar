import Foundation

enum PlantType: String, Codable, CaseIterable, Sendable {
    case ortaggio, aromatica, frutto, fiore, albero, altro

    var displayName: String {
        switch self {
        case .ortaggio: return "Ortaggio"
        case .aromatica: return "Aromatica"
        case .frutto: return "Frutto"
        case .fiore: return "Fiore"
        case .albero: return "Albero"
        case .altro: return "Altro"
        }
    }

    var emoji: String {
        switch self {
        case .ortaggio: return "🥦"
        case .aromatica: return "🌿"
        case .frutto: return "🍓"
        case .fiore: return "🌸"
        case .albero: return "🌳"
        case .altro: return "🌱"
        }
    }
}

enum EsposizioneBucket: String, CaseIterable, Sendable {
    case sole, mezzaOmbra, ombra
}

/// Bucketizza il campo testo libero `esposizione` (generato da AI extraction, es.
/// "Pieno sole (6+ ore)", "Sole o mezza ombra") in una categoria filtrabile.
/// Priorità: mezza ombra > ombra > sole, perché "mezza ombra" contiene "ombra" come sottostringa.
func esposizioneBucket(for esposizione: String?) -> EsposizioneBucket? {
    guard let testo = esposizione?.lowercased() else { return nil }
    if testo.contains("mezza ombra") || testo.contains("mezz'ombra") {
        return .mezzaOmbra
    }
    if testo.contains("ombra") {
        return .ombra
    }
    if testo.contains("sole") {
        return .sole
    }
    return nil
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

    // Campi agronomici (opzionali — piante legacy li hanno nil)
    let phMin: Double?
    let phMax: Double?
    let tempGermMin: Double?
    let tempOttMin: Double?
    let tempOttMax: Double?
    let tempTollMin: Double?
    let mesiFioritura: [Int]?

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
        case phMin = "ph_min"
        case phMax = "ph_max"
        case tempGermMin = "temp_germ_min"
        case tempOttMin = "temp_ott_min"
        case tempOttMax = "temp_ott_max"
        case tempTollMin = "temp_toll_min"
        case mesiFioritura = "mesi_fioritura"
    }

    init(
        id: UUID, slug: String, specieNome: String, growthDays: Int,
        attivitaSuggerite: [AttivitaSuggerita], seminaMesiEsterno: [Int],
        seminaMesiInterno: [Int], createdAt: Date, updatedAt: Date,
        specieNomeScentifico: String? = nil, descrizione: String? = nil,
        annaffiatura: String? = nil, esposizione: String? = nil,
        tipo: PlantType? = nil, difficolta: String? = nil,
        imageUrl: String? = nil, mesiRaccolta: [Int]? = nil,
        pianteCompagne: [String]? = nil, pianteIncompatibili: [String]? = nil,
        phMin: Double? = nil, phMax: Double? = nil,
        tempGermMin: Double? = nil, tempOttMin: Double? = nil, tempOttMax: Double? = nil,
        tempTollMin: Double? = nil, mesiFioritura: [Int]? = nil
    ) {
        self.id = id; self.slug = slug; self.specieNome = specieNome
        self.growthDays = growthDays; self.attivitaSuggerite = attivitaSuggerite
        self.seminaMesiEsterno = seminaMesiEsterno; self.seminaMesiInterno = seminaMesiInterno
        self.createdAt = createdAt; self.updatedAt = updatedAt
        self.specieNomeScentifico = specieNomeScentifico; self.descrizione = descrizione
        self.annaffiatura = annaffiatura; self.esposizione = esposizione
        self.tipo = tipo; self.difficolta = difficolta; self.imageUrl = imageUrl
        self.mesiRaccolta = mesiRaccolta; self.pianteCompagne = pianteCompagne
        self.pianteIncompatibili = pianteIncompatibili
        self.phMin = phMin; self.phMax = phMax
        self.tempGermMin = tempGermMin; self.tempOttMin = tempOttMin; self.tempOttMax = tempOttMax
        self.tempTollMin = tempTollMin; self.mesiFioritura = mesiFioritura
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

        phMin = try? c.decodeIfPresent(Double.self, forKey: .phMin)
        phMax = try? c.decodeIfPresent(Double.self, forKey: .phMax)
        tempGermMin = try? c.decodeIfPresent(Double.self, forKey: .tempGermMin)
        tempOttMin = try? c.decodeIfPresent(Double.self, forKey: .tempOttMin)
        tempOttMax = try? c.decodeIfPresent(Double.self, forKey: .tempOttMax)
        tempTollMin = try? c.decodeIfPresent(Double.self, forKey: .tempTollMin)
        mesiFioritura = try? c.decodeIfPresent([Int].self, forKey: .mesiFioritura)
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
