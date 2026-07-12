import Foundation

struct Orto: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let nome: String
    let luogo: String?
    let latitudine: Double?
    let longitudine: Double?
    let interno: Bool
    let fotoUrl: String?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case nome
        case luogo
        case latitudine
        case longitudine
        case interno
        case fotoUrl = "foto_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension Orto {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        userId = try c.decode(UUID.self, forKey: .userId)
        nome = try c.decode(String.self, forKey: .nome)
        luogo = try c.decodeIfPresent(String.self, forKey: .luogo)
        latitudine = try c.decodeIfPresent(Double.self, forKey: .latitudine)
        longitudine = try c.decodeIfPresent(Double.self, forKey: .longitudine)
        interno = try c.decodeIfPresent(Bool.self, forKey: .interno) ?? false
        fotoUrl = try c.decodeIfPresent(String.self, forKey: .fotoUrl)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)
    }
}

extension Orto {
    struct Create: Encodable {
        let nome: String
        let luogo: String?
        let latitudine: Double?
        let longitudine: Double?
        let interno: Bool
    }

    struct Update: Encodable {
        let nome: String?
        let luogo: String?
        let latitudine: Double?
        let longitudine: Double?
        let interno: Bool?
        var fotoUrl: String? = nil
        enum CodingKeys: String, CodingKey {
            case nome; case luogo; case latitudine; case longitudine; case interno
            case fotoUrl = "foto_url"
        }
    }
}
