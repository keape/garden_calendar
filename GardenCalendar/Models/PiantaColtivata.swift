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
    }
}
