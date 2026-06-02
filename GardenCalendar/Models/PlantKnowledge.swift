import Foundation

/// Modello per il catalogo delle specie vegetali (tabella Supabase `plant_knowledge`).
/// Le attività suggerite sono archiviate come JSON string e decodificate a richiesta.
struct PlantKnowledge: Codable, Identifiable {
    let id: UUID
    let slug: String
    let specieNome: String
    let growthDays: Int
    /// Stringa JSON contenente un array di `AttivitaSuggerita`.
    let attivitaSuggerite: String
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case slug
        case specieNome = "specie_nome"
        case growthDays = "growth_days"
        case attivitaSuggerite = "attivita_suggerite"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    /// Decodifica la stringa JSON `attivitaSuggerite` in un array di `AttivitaSuggerita`.
    /// Restituisce un array vuoto in caso di errore di parsing.
    var attivitaSuggeriteDecodificate: [AttivitaSuggerita] {
        guard let data = attivitaSuggerite.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([AttivitaSuggerita].self, from: data)) ?? []
    }
}

// MARK: - Attività suggerita per una specie

extension PlantKnowledge {
    struct AttivitaSuggerita: Codable {
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
