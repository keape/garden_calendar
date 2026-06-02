import Foundation
import Supabase

enum SupabaseConfig {
    static let supabaseURL = URL(string: "https://kusprtmfxrsnjycyzlgs.supabase.co")!
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt1c3BydG1meHJzbmp5Y3l6bGdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk2NTE2OTUsImV4cCI6MjA5NTIyNzY5NX0.Xy9otBRvHYRjOFG7WJmYv-pla6lzIxbL7fF9xXFNZBY"

    static let client: SupabaseClient = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            // timestamptz: "2026-05-29T14:00:00.000000+00:00" or "2026-05-29T14:00:00"
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso.date(from: string) { return date }
            iso.formatOptions = [.withInternetDateTime]
            if let date = iso.date(from: string) { return date }

            // date: "2026-05-29" (PostgreSQL date type)
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = df.date(from: string) { return date }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(string)"
            )
        }

        return SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseAnonKey,
            options: SupabaseClientOptions(
                db: .init(decoder: decoder)
            )
        )
    }()
}
