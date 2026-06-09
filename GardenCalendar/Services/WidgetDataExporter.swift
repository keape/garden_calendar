import Foundation
import WidgetKit

enum WidgetDataExporter {
    /// Scrive le attività dei prossimi 2 giorni nel container condiviso e aggiorna il widget.
    static func export(activities: [Attivita], piante: [PiantaColtivata]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let limit = calendar.date(byAdding: .day, value: 2, to: today) else { return }

        let pianteNames = Dictionary(uniqueKeysWithValues: piante.map { ($0.id, $0.nomePersonalizzato) })

        let snapshot = activities
            .filter { $0.data >= today && $0.data < limit }
            .sorted { $0.data < $1.data }
            .map {
                WidgetActivity(
                    id: $0.id,
                    nome: $0.nome,
                    piantaNome: pianteNames[$0.piantaId],
                    data: $0.data,
                    done: $0.done,
                    color: $0.color
                )
            }

        LocalCache.save(snapshot, key: LocalCache.todayActivitiesKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "GardenCalendarWidget")
    }
}
