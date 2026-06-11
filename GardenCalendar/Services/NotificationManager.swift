import Foundation
import UserNotifications

/// Notifiche locali: promemoria mattutino con le attività del giorno.
@MainActor
@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    static let enabledKey = "notificheAttive"
    static let hourKey = "notificheOra"

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Self.enabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.enabledKey) }
    }

    /// Ora della notifica giornaliera (default 8:00).
    var notificationHour: Int {
        get {
            let h = UserDefaults.standard.integer(forKey: Self.hourKey)
            return h == 0 ? 8 : h
        }
        set { UserDefaults.standard.set(newValue, forKey: Self.hourKey) }
    }

    private init() {}

    /// Chiede il permesso. Ritorna true se concesso.
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        default:
            return false
        }
    }

    /// Riprogramma le notifiche per i prossimi 7 giorni in base alle attività non completate.
    /// Chiamare dopo ogni caricamento/modifica del calendario.
    func reschedule(activities: [Attivita]) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: (0..<7).map { "daily-activities-\($0)" })

        guard isEnabled else { return }
        guard await requestAuthorization() else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            let dayActivities = activities.filter {
                !$0.done && calendar.isDate($0.data, inSameDayAs: day)
            }
            guard !dayActivities.isEmpty else { continue }

            var fireComponents = calendar.dateComponents([.year, .month, .day], from: day)
            fireComponents.hour = notificationHour
            fireComponents.minute = 0
            guard let fireDate = calendar.date(from: fireComponents), fireDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            let notifLang = LanguageManager.shared
            content.title = notifLang.notifications.dailyTitle
            let names = dayActivities.map { $0.nome.capitalized }
            let unique = Array(NSOrderedSet(array: names)) as? [String] ?? names
            let summary = unique.prefix(3).joined(separator: ", ")
            let extra = dayActivities.count > 3 ? notifLang.notifications.andMore : ""
            content.body = String(format: notifLang.notifications.activitiesCountFormat,
                                  dayActivities.count, summary, extra)
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate),
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: "daily-activities-\(offset)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: (0..<7).map { "daily-activities-\($0)" }
        )
    }
}
