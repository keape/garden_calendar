import Foundation

// MARK: - Open-Meteo API

actor OpenMeteoClient {
    static let shared = OpenMeteoClient()
    private let cache: NSCache<NSString, CacheEntry> = {
        let c = NSCache<NSString, CacheEntry>()
        c.countLimit = 50
        return c
    }()
    private var inFlight: [String: Task<[String: Bool], Error>] = [:]

    private init() {}

    /// Fetch rain days for a location and date range.
    /// Returns a Set of "YYYY-MM-DD" date strings where precipitation >= threshold mm.
    func fetchRainDays(latitude: Double, longitude: Double, from: Date, to: Date, threshold: Double = 2.0) async throws -> [String: Bool] {
        let key = "\(latitude),\(longitude),\(from.iso8601),\(to.iso8601),\(threshold)"

        // Check cache
        if let cached = cache.object(forKey: key as NSString) {
            return cached.days
        }

        // Dedup in-flight requests
        if let existing = inFlight[key] {
            return try await existing.value
        }

        let task = Task<[String: Bool], Error> {
            defer { inFlight.removeValue(forKey: key) }

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            let fromStr = formatter.string(from: from)
            let toStr = formatter.string(from: to)

            let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=precipitation_sum&timezone=auto&start_date=\(fromStr)&end_date=\(toStr)"

            guard let url = URL(string: urlStr) else {
                throw RainError.invalidURL
            }

            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw RainError.apiError
            }

            let decoder = JSONDecoder()
            let result = try decoder.decode(OpenMeteoResponse.self, from: data)

            var days: [String: Bool] = [:]
            for (index, dateStr) in result.daily.time.enumerated() {
                let precip = index < result.daily.precipitationSum.count ? result.daily.precipitationSum[index] : 0
                if precip >= threshold {
                    days[dateStr] = true
                }
            }

            // Cache for 6 hours
            let entry = CacheEntry(days: days, timestamp: Date())
            cache.setObject(entry, forKey: key as NSString)

            return days
        }

        inFlight[key] = task
        return try await task.value
    }
}

// MARK: - Rain Adjuster

struct RainAdjuster {
    /// Check if a rain day falls today or yesterday relative to an activity date.
    static func isAbsorbedByRain(activityDate: Date, rainDays: [String: Bool]) -> Bool {
        let calendar = Calendar.current
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        let todayStr = formatter.string(from: activityDate)
        let yesterdayStr = formatter.string(from: calendar.date(byAdding: .day, value: -1, to: activityDate) ?? activityDate)

        return rainDays[todayStr] == true || rainDays[yesterdayStr] == true
    }

    /// Compute rain overrides for a list of activities.
    /// Returns a set of activity IDs that should be marked as rain-absorbed.
    static func computeOverrides(activities: [Attivita], rainDays: [String: Bool]) -> Set<UUID> {
        var absorbed = Set<UUID>()

        for activity in activities {
            // Only AI-suggested irrigation activities
            guard !activity.userEvent else { continue }
            guard isIrrigation(name: activity.nome) else { continue }

            if isAbsorbedByRain(activityDate: activity.data, rainDays: rainDays) {
                absorbed.insert(activity.id)
            }
        }

        return absorbed
    }

    static func isIrrigation(name: String) -> Bool {
        let n = name.lowercased()
        return n.contains("irrigaz") || n.contains("acqua") || n.contains("bevuta")
    }

    static func computeRescheduling(
        activities: [Attivita],
        rainDays: [String: Bool]
    ) -> [RescheduleAction] {
        let calendar = Calendar.current
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        return activities.compactMap { activity in
            guard !activity.userEvent,
                  !activity.rainAdjusted,       // already processed: markRainAbsorbed sets both flags atomically
                  !activity.rainRescheduled,
                  let recDays = activity.recurrenceDays, recDays > 0,
                  isIrrigation(name: activity.nome)
            else { return nil }

            let actStr = formatter.string(from: activity.data)
            let dayBefore = calendar.date(byAdding: .day, value: -1, to: activity.data) ?? activity.data
            let dayBeforeStr = formatter.string(from: dayBefore)

            let rainDate: Date
            if rainDays[actStr] == true {
                rainDate = activity.data
            } else if rainDays[dayBeforeStr] == true {
                rainDate = dayBefore
            } else {
                return nil
            }

            return RescheduleAction(
                absorbedId: activity.id,
                absorbedDate: activity.data,
                piantaId: activity.piantaId,
                nome: activity.nome,
                recurrenceDays: recDays,
                rainDate: rainDate
            )
        }
    }
}

struct RescheduleAction {
    let absorbedId: UUID
    let absorbedDate: Date   // data dell'attività assorbita (non la data pioggia)
    let piantaId: UUID
    let nome: String
    let recurrenceDays: Int
    let rainDate: Date
    var newDate: Date {
        Calendar.current.date(byAdding: .day, value: recurrenceDays, to: rainDate) ?? rainDate
    }
}

// MARK: - Models

private struct OpenMeteoResponse: Decodable {
    let daily: Daily

    struct Daily: Decodable {
        let time: [String]
        let precipitationSum: [Double]

        enum CodingKeys: String, CodingKey {
            case time
            case precipitationSum = "precipitation_sum"
        }
    }
}

private class CacheEntry {
    let days: [String: Bool]
    let timestamp: Date
    init(days: [String: Bool], timestamp: Date) {
        self.days = days
        self.timestamp = timestamp
    }
}

enum RainError: LocalizedError {
    case invalidURL
    case apiError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL Open-Meteo non valido"
        case .apiError: return "Errore API Open-Meteo"
        }
    }
}

// MARK: - Date Extension

private extension Date {
    var iso8601: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: self)
    }
}
