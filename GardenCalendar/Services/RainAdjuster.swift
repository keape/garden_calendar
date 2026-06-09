import Foundation

// MARK: - Open-Meteo API

/// Meteo giornaliero per una località: pioggia (mm, solo giorni >= soglia) e gelate (°C min, solo giorni <= soglia).
struct DailyWeather {
    var rainDays: [String: Double] = [:]
    var frostDays: [String: Double] = [:]
}

actor OpenMeteoClient {
    static let shared = OpenMeteoClient()
    /// Sotto questa temperatura minima (°C) un giorno è considerato a rischio gelata.
    static let frostThreshold = 2.0

    private let cache: NSCache<NSString, CacheEntry> = {
        let c = NSCache<NSString, CacheEntry>()
        c.countLimit = 50
        return c
    }()
    private var inFlight: [String: Task<DailyWeather, Error>] = [:]

    private init() {}

    /// Fetch daily weather (rain + min temperature) for a location and date range.
    func fetchDaily(latitude: Double, longitude: Double, from: Date, to: Date, rainThreshold: Double = 2.0) async throws -> DailyWeather {
        let clampedTo = min(to, Calendar.current.date(byAdding: .day, value: 16, to: Date()) ?? to)
        let key = "\(latitude),\(longitude),\(from.iso8601),\(clampedTo.iso8601),\(rainThreshold)"

        // Check cache (valid 6 hours)
        if let cached = cache.object(forKey: key as NSString) {
            if Date().timeIntervalSince(cached.timestamp) < 6 * 3600 {
                return cached.weather
            }
            cache.removeObject(forKey: key as NSString)
        }

        // Dedup in-flight requests
        if let existing = inFlight[key] {
            return try await existing.value
        }

        let task = Task<DailyWeather, Error> {
            defer { inFlight.removeValue(forKey: key) }

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            let fromStr = formatter.string(from: from)
            let toStr = formatter.string(from: clampedTo)

            let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=precipitation_sum,temperature_2m_min&timezone=auto&start_date=\(fromStr)&end_date=\(toStr)"

            guard let url = URL(string: urlStr) else {
                throw RainError.invalidURL
            }

            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw RainError.apiError
            }

            let decoder = JSONDecoder()
            let result = try decoder.decode(OpenMeteoResponse.self, from: data)

            var weather = DailyWeather()
            for (index, dateStr) in result.daily.time.enumerated() {
                let precip = index < result.daily.precipitationSum.count ? result.daily.precipitationSum[index] : 0
                if precip >= rainThreshold {
                    weather.rainDays[dateStr] = precip
                }
                if let tMins = result.daily.temperatureMin,
                   index < tMins.count,
                   let tMin = tMins[index],
                   tMin <= Self.frostThreshold {
                    weather.frostDays[dateStr] = tMin
                }
            }

            let entry = CacheEntry(weather: weather, timestamp: Date())
            cache.setObject(entry, forKey: key as NSString)

            return weather
        }

        inFlight[key] = task
        return try await task.value
    }

    /// Compat: solo i giorni di pioggia.
    func fetchRainDays(latitude: Double, longitude: Double, from: Date, to: Date, threshold: Double = 2.0) async throws -> [String: Double] {
        try await fetchDaily(latitude: latitude, longitude: longitude, from: from, to: to, rainThreshold: threshold).rainDays
    }
}

// MARK: - Rain Adjuster

struct RainAdjuster {
    /// Check if a rain day falls today or yesterday relative to an activity date.
    static func isAbsorbedByRain(activityDate: Date, rainDays: [String: Double]) -> Bool {
        let calendar = Calendar.current
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        let todayStr = formatter.string(from: activityDate)
        let yesterdayStr = formatter.string(from: calendar.date(byAdding: .day, value: -1, to: activityDate) ?? activityDate)

        return rainDays[todayStr] != nil || rainDays[yesterdayStr] != nil
    }

    /// Compute rain overrides for a list of activities.
    /// Returns a set of activity IDs that should be marked as rain-absorbed.
    static func computeOverrides(activities: [Attivita], rainDays: [String: Double]) -> Set<UUID> {
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
        rainDays: [String: Double]
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
            if rainDays[actStr] != nil {
                rainDate = activity.data
            } else if rainDays[dayBeforeStr] != nil {
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
        let temperatureMin: [Double?]?

        enum CodingKeys: String, CodingKey {
            case time
            case precipitationSum = "precipitation_sum"
            case temperatureMin = "temperature_2m_min"
        }
    }
}

private class CacheEntry {
    let weather: DailyWeather
    let timestamp: Date
    init(weather: DailyWeather, timestamp: Date) {
        self.weather = weather
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
