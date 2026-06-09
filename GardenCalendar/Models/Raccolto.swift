import Foundation

/// Raccolto registrato per una pianta (quantità + unità, es. 2.5 kg di pomodori).
struct Raccolto: Codable, Identifiable, Hashable {
    let id: UUID
    let piantaId: UUID
    let data: Date
    let quantita: Double
    let unita: String
    let note: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case piantaId = "pianta_id"
        case data
        case quantita
        case unita
        case note
        case createdAt = "created_at"
    }
}

/// DTO per creare un raccolto.
struct RaccoltoCreate: Encodable {
    let piantaId: UUID
    let data: Date
    let quantita: Double
    let unita: String
    let note: String?

    enum CodingKeys: String, CodingKey {
        case piantaId = "pianta_id"
        case data
        case quantita
        case unita
        case note
    }
}
