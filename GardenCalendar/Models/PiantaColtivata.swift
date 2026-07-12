import Foundation

struct PiantaColtivata: Codable, Identifiable, Hashable {
    let id: UUID
    let ortoId: UUID
    let specieId: UUID?
    let nomePersonalizzato: String
    let dataSemina: Date
    let growthDays: Int
    let note: String?
    let fotoUrl: String?
    let activityOverrides: [ActivityOverride]?
    let createdAt: Date
    let updatedAt: Date

    var dataRaccoltaPrevista: Date {
        Calendar.current.date(byAdding: .day, value: growthDays, to: dataSemina) ?? dataSemina
    }

    enum CodingKeys: String, CodingKey {
        case id
        case ortoId = "orto_id"
        case specieId = "specie_id"
        case nomePersonalizzato = "nome_personalizzato"
        case dataSemina = "data_semina"
        case growthDays = "growth_days"
        case note
        case fotoUrl = "foto_url"
        case activityOverrides = "activity_overrides"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    /// Giorni trascorsi dalla semina a oggi.
    var giorniTrascorsi: Int {
        Calendar.current.dateComponents([.day], from: dataSemina, to: Date()).day ?? 0
    }

    /// Progresso del ciclo di crescita, normalizzato tra 0.0 e 1.0.
    /// Se growthDays <= 0, restituisce 0.
    var progressoCiclo: Double {
        guard growthDays > 0 else { return 0 }
        return min(Double(giorniTrascorsi) / Double(growthDays), 1.0)
    }
}

// MARK: - DTO per le mutate API

/// La colonna `data_semina` è di tipo `date` (no timezone): va inviata come
/// stringa "yyyy-MM-dd" nel calendario locale, non come timestamp ISO8601 UTC
/// (altrimenti Postgres tronca al giorno UTC, che per fusi orari positivi è
/// sempre il giorno precedente a mezzanotte locale).
private let dataSeminaFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate]
    formatter.timeZone = .current
    return formatter
}()

extension PiantaColtivata {
    struct Create: Encodable {
        let ortoId: UUID
        let specieId: UUID?
        let nomePersonalizzato: String
        let dataSemina: Date
        let growthDays: Int
        let note: String?
        let fotoUrl: String?

        enum CodingKeys: String, CodingKey {
            case ortoId = "orto_id"
            case specieId = "specie_id"
            case nomePersonalizzato = "nome_personalizzato"
            case dataSemina = "data_semina"
            case growthDays = "growth_days"
            case note
            case fotoUrl = "foto_url"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(ortoId, forKey: .ortoId)
            try container.encode(specieId, forKey: .specieId)
            try container.encode(nomePersonalizzato, forKey: .nomePersonalizzato)
            try container.encode(dataSeminaFormatter.string(from: dataSemina), forKey: .dataSemina)
            try container.encode(growthDays, forKey: .growthDays)
            try container.encode(note, forKey: .note)
            try container.encode(fotoUrl, forKey: .fotoUrl)
        }
    }

    struct Update: Encodable {
        let nomePersonalizzato: String?
        let dataSemina: Date?
        let growthDays: Int?
        let note: String?
        let fotoUrl: String?

        enum CodingKeys: String, CodingKey {
            case nomePersonalizzato = "nome_personalizzato"
            case dataSemina = "data_semina"
            case growthDays = "growth_days"
            case note
            case fotoUrl = "foto_url"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(nomePersonalizzato, forKey: .nomePersonalizzato)
            try container.encode(dataSemina.map { dataSeminaFormatter.string(from: $0) }, forKey: .dataSemina)
            try container.encode(growthDays, forKey: .growthDays)
            try container.encode(note, forKey: .note)
            try container.encode(fotoUrl, forKey: .fotoUrl)
        }
    }

    struct ActivityOverride: Codable, Hashable {
        let nome: String
        let recurrenceDays: Int?
        let offsetDays: Int?

        enum CodingKeys: String, CodingKey {
            case nome
            case recurrenceDays = "recurrence_days"
            case offsetDays = "offset_days"
        }
    }
}
