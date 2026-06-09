import Foundation

/// Cache locale read-only per consultare i dati senza rete (es. nell'orto senza segnale).
/// Scrive JSON nel container App Group se disponibile (condiviso col widget),
/// altrimenti in Application Support.
enum LocalCache {
    static let appGroupId = "group.com.gardencalendar.app"

    private static var baseURL: URL? {
        if let group = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) {
            return group.appendingPathComponent("Cache", isDirectory: true)
        }
        guard let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        return support.appendingPathComponent("LocalCache", isDirectory: true)
    }

    private static func fileURL(for key: String) -> URL? {
        guard let base = baseURL else { return nil }
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base.appendingPathComponent("\(key).json")
    }

    /// Encoder/decoder allineati a SupabaseConfig (date ISO8601).
    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    static func save<T: Encodable>(_ value: T, key: String) {
        guard let url = fileURL(for: key),
              let data = try? encoder.encode(value) else { return }
        try? data.write(to: url, options: .atomic)
    }

    static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let url = fileURL(for: key),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    // MARK: - Chiavi

    static func monthKey(for date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month], from: date)
        return "attivita-\(c.year ?? 0)-\(c.month ?? 0)"
    }

    static let pianteKey = "piante"
    static let ortiKey = "orti"
    static let todayActivitiesKey = "today-activities"
}
