import Foundation

struct Orto: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let nome: String
    let luogo: String?
    let latitudine: Double?
    let longitudine: Double?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case nome
        case luogo
        case latitudine
        case longitudine
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension Orto {
    struct Create: Encodable {
        let nome: String
        let luogo: String?
        let latitudine: Double?
        let longitudine: Double?
    }

    struct Update: Encodable {
        let nome: String?
        let luogo: String?
        let latitudine: Double?
        let longitudine: Double?
    }
}
