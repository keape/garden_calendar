import Foundation

// MARK: - Open-Meteo Archive API (normali climatiche mensili)

/// Temperature medie mensili (1-12) per una posizione, ricavate dallo storico Open-Meteo Archive.
struct MonthlyClimateNormals: Sendable {
    /// [mese: temperatura media (°C)]
    var meanTemp: [Int: Double] = [:]
    /// [mese: media delle temperature minime giornaliere (°C)]
    var meanMinTemp: [Int: Double] = [:]
}

actor ClimateNormalsClient {
    static let shared = ClimateNormalsClient()

    private let cache: NSCache<NSString, CacheEntry> = {
        let c = NSCache<NSString, CacheEntry>()
        c.countLimit = 50
        return c
    }()
    private var inFlight: [String: Task<MonthlyClimateNormals, Error>] = [:]

    private init() {}

    /// Normali climatiche mensili calcolate sugli ultimi `years` anni di storico per le coordinate date.
    /// Arrotonda le coordinate a 0.1° per aumentare i cache hit tra giardini vicini.
    func fetchNormals(latitude: Double, longitude: Double, years: Int = 5) async throws -> MonthlyClimateNormals {
        let lat = (latitude * 10).rounded() / 10
        let lon = (longitude * 10).rounded() / 10
        let key = "\(lat),\(lon),\(years)"

        // Cache valida a lungo: le normali climatiche cambiano poco nel tempo.
        if let cached = cache.object(forKey: key as NSString) {
            if Date().timeIntervalSince(cached.timestamp) < 30 * 24 * 3600 {
                return cached.normals
            }
            cache.removeObject(forKey: key as NSString)
        }

        if let existing = inFlight[key] {
            return try await existing.value
        }

        let task = Task<MonthlyClimateNormals, Error> {
            defer { inFlight.removeValue(forKey: key) }

            let calendar = Calendar(identifier: .gregorian)
            let today = Date()
            // Lo storico Archive ha un ritardo di alcuni giorni: chiudiamo a 7 giorni fa.
            let end = calendar.date(byAdding: .day, value: -7, to: today) ?? today
            let start = calendar.date(byAdding: .year, value: -years, to: end) ?? end

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            let startStr = formatter.string(from: start)
            let endStr = formatter.string(from: end)

            let urlStr = "https://archive-api.open-meteo.com/v1/archive?latitude=\(lat)&longitude=\(lon)&start_date=\(startStr)&end_date=\(endStr)&daily=temperature_2m_mean,temperature_2m_min&timezone=auto"

            guard let url = URL(string: urlStr) else {
                throw ClimateError.invalidURL
            }

            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ClimateError.apiError
            }

            let decoder = JSONDecoder()
            let result = try decoder.decode(ArchiveResponse.self, from: data)

            var meanSums: [Int: Double] = [:]
            var meanCounts: [Int: Int] = [:]
            var minSums: [Int: Double] = [:]
            var minCounts: [Int: Int] = [:]

            for (index, dateStr) in result.daily.time.enumerated() {
                guard let month = Self.month(from: dateStr) else { continue }
                if index < result.daily.temperatureMean.count, let mean = result.daily.temperatureMean[index] {
                    meanSums[month, default: 0] += mean
                    meanCounts[month, default: 0] += 1
                }
                if index < result.daily.temperatureMin.count, let min = result.daily.temperatureMin[index] {
                    minSums[month, default: 0] += min
                    minCounts[month, default: 0] += 1
                }
            }

            var normals = MonthlyClimateNormals()
            for month in 1...12 {
                if let count = meanCounts[month], count > 0 {
                    normals.meanTemp[month] = meanSums[month]! / Double(count)
                }
                if let count = minCounts[month], count > 0 {
                    normals.meanMinTemp[month] = minSums[month]! / Double(count)
                }
            }

            let entry = CacheEntry(normals: normals, timestamp: Date())
            self.cache.setObject(entry, forKey: key as NSString)

            return normals
        }

        inFlight[key] = task
        return try await task.value
    }

    private static func month(from isoDate: String) -> Int? {
        // Formato atteso: "YYYY-MM-DD"
        let parts = isoDate.split(separator: "-")
        guard parts.count >= 2, let month = Int(parts[1]) else { return nil }
        return month
    }
}

// MARK: - Models

private struct ArchiveResponse: Decodable {
    let daily: Daily

    struct Daily: Decodable {
        let time: [String]
        let temperatureMean: [Double?]
        let temperatureMin: [Double?]

        enum CodingKeys: String, CodingKey {
            case time
            case temperatureMean = "temperature_2m_mean"
            case temperatureMin = "temperature_2m_min"
        }
    }
}

private class CacheEntry {
    let normals: MonthlyClimateNormals
    let timestamp: Date
    init(normals: MonthlyClimateNormals, timestamp: Date) {
        self.normals = normals
        self.timestamp = timestamp
    }
}

enum ClimateError: LocalizedError {
    case invalidURL
    case apiError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL Open-Meteo Archive non valido"
        case .apiError: return "Errore nel recupero delle normali climatiche"
        }
    }
}
