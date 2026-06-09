import WidgetKit
import SwiftUI

// MARK: - Timeline

struct ActivitiesEntry: TimelineEntry {
    let date: Date
    let activities: [WidgetActivity]
}

struct ActivitiesProvider: TimelineProvider {
    func placeholder(in context: Context) -> ActivitiesEntry {
        ActivitiesEntry(date: Date(), activities: [
            WidgetActivity(id: UUID(), nome: "Irrigazione", piantaNome: "Pomodoro", data: Date(), done: false, color: "blue"),
            WidgetActivity(id: UUID(), nome: "Concimazione", piantaNome: "Basilico", data: Date(), done: false, color: "green")
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (ActivitiesEntry) -> Void) {
        completion(ActivitiesEntry(date: Date(), activities: todayActivities()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ActivitiesEntry>) -> Void) {
        let entry = ActivitiesEntry(date: Date(), activities: todayActivities())
        // Aggiorna a mezzanotte per passare al giorno successivo.
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date())
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func todayActivities() -> [WidgetActivity] {
        let all: [WidgetActivity] = LocalCache.load([WidgetActivity].self, key: LocalCache.todayActivitiesKey) ?? []
        return all.filter { Calendar.current.isDateInToday($0.data) }
    }
}

// MARK: - View

struct GardenCalendarWidgetView: View {
    var entry: ActivitiesEntry
    @Environment(\.widgetFamily) private var family

    private var pending: [WidgetActivity] { entry.activities.filter { !$0.done } }
    private var maxRows: Int { family == .systemMedium ? 3 : 2 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text("🌱")
                Text("Oggi nell'orto")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                if !pending.isEmpty {
                    Text("\(pending.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.green))
                }
            }

            if pending.isEmpty {
                Spacer()
                Text(entry.activities.isEmpty ? "Nessuna attività oggi" : "Tutto fatto! 🎉")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ForEach(pending.prefix(maxRows)) { activity in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(color(for: activity.color))
                            .frame(width: 8, height: 8)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(activity.nome.capitalized)
                                .font(.footnote.weight(.medium))
                                .lineLimit(1)
                            if let pianta = activity.piantaNome {
                                Text(pianta)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
                if pending.count > maxRows {
                    Text("+\(pending.count - maxRows) altre")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func color(for name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "brown": return .brown
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        default: return .green
        }
    }
}

// MARK: - Widget

struct GardenCalendarWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "GardenCalendarWidget", provider: ActivitiesProvider()) { entry in
            GardenCalendarWidgetView(entry: entry)
        }
        .configurationDisplayName("Attività di oggi")
        .description("Le attività del giorno nel tuo orto.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct GardenCalendarWidgetBundle: WidgetBundle {
    var body: some Widget {
        GardenCalendarWidget()
    }
}
