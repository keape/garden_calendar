import Foundation

/// Snapshot leggero delle attività di oggi/domani per il widget home screen.
/// Condiviso via App Group (vedi LocalCache.appGroupId).
/// Compilato sia nell'app che nell'estensione widget.
struct WidgetActivity: Codable, Identifiable {
    let id: UUID
    let nome: String
    let piantaNome: String?
    let data: Date
    let done: Bool
    let color: String
}
