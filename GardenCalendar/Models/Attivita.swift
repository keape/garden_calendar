import Foundation
import SwiftUI

struct Attivita: Codable, Identifiable {
    let id: UUID
    let piantaId: UUID
    let nome: String
    let data: Date
    var done: Bool
    let rainAdjusted: Bool
    let rainRescheduled: Bool
    let userEvent: Bool
    let sourceAction: String?
    let note: String?
    let color: String
    let recurrenceDays: Int?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case piantaId = "pianta_id"
        case nome
        case data
        case done
        case rainAdjusted = "rain_adjusted"
        case rainRescheduled = "rain_rescheduled"
        case userEvent = "user_event"
        case sourceAction = "source_action"
        case note
        case color
        case recurrenceDays = "recurrence_days"
        case createdAt = "created_at"
    }

    /// `true` se l'attività è già passata rispetto a oggi.
    var isPassata: Bool {
        data < Date()
    }

    /// Colore SwiftUI derivato dalla stringa `color`.
    var colorValue: Color {
        switch color.lowercased() {
        case "green", "verde":
            return .green
        case "orange", "arancione":
            return .orange
        case "blue", "blu", "blue":
            return .blue
        case "red", "rosso":
            return .red
        case "gray", "grigio":
            return .gray
        case "purple", "viola":
            return .purple
        case "yellow", "giallo":
            return .yellow
        case "pink", "rosa":
            return .pink
        default:
            return .accentColor
        }
    }
}

// MARK: - DTO per le mutate API

extension Attivita {
    struct Create: Encodable {
        let piantaId: UUID
        let nome: String
        let data: Date
        let done: Bool
        let rainAdjusted: Bool
        let rainRescheduled: Bool
        let userEvent: Bool
        let sourceAction: String?
        let note: String?
        let color: String
        let recurrenceDays: Int?

        enum CodingKeys: String, CodingKey {
            case piantaId = "pianta_id"
            case nome
            case data
            case done
            case rainAdjusted = "rain_adjusted"
            case rainRescheduled = "rain_rescheduled"
            case userEvent = "user_event"
            case sourceAction = "source_action"
            case note
            case color
            case recurrenceDays = "recurrence_days"
        }
    }

    struct Update: Encodable {
        let nome: String?
        let data: Date?
        let done: Bool?
        let rainAdjusted: Bool?
        let rainRescheduled: Bool?
        let userEvent: Bool?
        let sourceAction: String?
        let note: String?
        let color: String?
        let recurrenceDays: Int?

        enum CodingKeys: String, CodingKey {
            case nome
            case data
            case done
            case rainAdjusted = "rain_adjusted"
            case rainRescheduled = "rain_rescheduled"
            case userEvent = "user_event"
            case sourceAction = "source_action"
            case note
            case color
            case recurrenceDays = "recurrence_days"
        }
    }
}
