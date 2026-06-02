import Foundation

struct WikiNote: Codable, Identifiable {
    let id: UUID
    let slug: String
    let markdownContent: String
    let processed: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case slug
        case markdownContent = "markdown_content"
        case processed
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
