import Foundation

/// Categoria della pianta coltivata: determina se ha un ciclo di crescita
/// verso un raccolto (orto) o cure ricorrenti senza raccolto (ornamentale).
enum PiantaCategoria: String, Codable, CaseIterable, Sendable {
    case raccolto, ornamentale
}

struct PiantaColtivata: Codable, Identifiable, Hashable {
    let id: UUID
    let ortoId: UUID
    let specieId: UUID?
    let nomePersonalizzato: String
    let dataSemina: Date
    let growthDays: Int
    let tipo: PiantaCategoria
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
        case tipo
        case note
        case fotoUrl = "foto_url"
        case activityOverrides = "activity_overrides"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        ortoId = try container.decode(UUID.self, forKey: .ortoId)
        specieId = try container.decodeIfPresent(UUID.self, forKey: .specieId)
        nomePersonalizzato = try container.decode(String.self, forKey: .nomePersonalizzato)
        dataSemina = try container.decode(Date.self, forKey: .dataSemina)
        growthDays = try container.decode(Int.self, forKey: .growthDays)
        // Righe legacy (create prima della colonna `tipo`) restano `.raccolto`.
        tipo = try container.decodeIfPresent(PiantaCategoria.self, forKey: .tipo) ?? .raccolto
        note = try container.decodeIfPresent(String.self, forKey: .note)
        fotoUrl = try container.decodeIfPresent(String.self, forKey: .fotoUrl)
        activityOverrides = try container.decodeIfPresent([ActivityOverride].self, forKey: .activityOverrides)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    init(
        id: UUID, ortoId: UUID, specieId: UUID?, nomePersonalizzato: String,
        dataSemina: Date, growthDays: Int, tipo: PiantaCategoria, note: String?,
        fotoUrl: String?, activityOverrides: [ActivityOverride]?, createdAt: Date, updatedAt: Date
    ) {
        self.id = id
        self.ortoId = ortoId
        self.specieId = specieId
        self.nomePersonalizzato = nomePersonalizzato
        self.dataSemina = dataSemina
        self.growthDays = growthDays
        self.tipo = tipo
        self.note = note
        self.fotoUrl = fotoUrl
        self.activityOverrides = activityOverrides
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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
        let tipo: PiantaCategoria
        let note: String?
        let fotoUrl: String?

        init(
            ortoId: UUID, specieId: UUID?, nomePersonalizzato: String, dataSemina: Date,
            growthDays: Int, tipo: PiantaCategoria = .raccolto, note: String?, fotoUrl: String?
        ) {
            self.ortoId = ortoId
            self.specieId = specieId
            self.nomePersonalizzato = nomePersonalizzato
            self.dataSemina = dataSemina
            self.growthDays = growthDays
            self.tipo = tipo
            self.note = note
            self.fotoUrl = fotoUrl
        }

        enum CodingKeys: String, CodingKey {
            case ortoId = "orto_id"
            case specieId = "specie_id"
            case nomePersonalizzato = "nome_personalizzato"
            case dataSemina = "data_semina"
            case growthDays = "growth_days"
            case tipo
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
            try container.encode(tipo, forKey: .tipo)
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
