import Foundation
import Supabase

@Observable
final class SupabaseRepository {
    static let shared = SupabaseRepository()

    private let client = SupabaseConfig.client

    private init() {}

    // MARK: - Orti

    func fetchOrti(userId: UUID) async throws -> [Orto] {
        try await client
            .from("orti")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    func createOrto(userId: UUID, orto: Orto.Create) async throws -> Orto {
        struct Body: Encodable {
            let userId: UUID
            let nome: String
            let luogo: String?
            let latitudine: Double?
            let longitudine: Double?
            enum CodingKeys: String, CodingKey {
                case userId = "user_id"; case nome; case luogo; case latitudine; case longitudine
            }
        }
        return try await client
            .from("orti")
            .insert(Body(userId: userId, nome: orto.nome, luogo: orto.luogo, latitudine: orto.latitudine, longitudine: orto.longitudine), returning: .representation)
            .select()
            .single()
            .execute()
            .value
    }

    func updateOrto(id: UUID, orto: Orto.Update) async throws -> Orto {
        try await client
            .from("orti")
            .update(orto, returning: .representation)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value
    }

    func deleteOrto(id: UUID) async throws {
        try await client
            .from("orti")
            .delete()
            .eq("id", value: id)
            .execute()
    }

    // MARK: - Piante Coltivate

    func fetchPiante(ortoId: UUID) async throws -> [PiantaColtivata] {
        try await client
            .from("piante_coltivate")
            .select()
            .eq("orto_id", value: ortoId)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    func fetchAllPiante(userId: UUID) async throws -> [PiantaColtivata] {
        let orti = try await fetchOrti(userId: userId)
        var result: [PiantaColtivata] = []
        for orto in orti {
            let piante = try await fetchPiante(ortoId: orto.id)
            result.append(contentsOf: piante)
        }
        return result
    }

    func createPianta(pianta: PiantaColtivata.Create) async throws -> PiantaColtivata {
        try await client
            .from("piante_coltivate")
            .insert(pianta, returning: .representation)
            .select()
            .single()
            .execute()
            .value
    }

    func updatePianta(id: UUID, pianta: PiantaColtivata.Update) async throws -> PiantaColtivata {
        try await client
            .from("piante_coltivate")
            .update(pianta, returning: .representation)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value
    }

    func deletePianta(id: UUID) async throws {
        try await client
            .from("piante_coltivate")
            .delete()
            .eq("id", value: id)
            .execute()
    }

    // MARK: - Attività

    func fetchAttivita(piantaId: UUID? = nil, date: Date? = nil) async throws -> [Attivita] {
        var query = client
            .from("attivita")
            .select()

        if let piantaId {
            query = query.eq("pianta_id", value: piantaId)
        }
        if let date {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: date)
            guard let startOfMonth = calendar.date(from: components),
                  let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
                throw RepositoryError.invalidDate
            }
            query = query
                .gte("data", value: startOfMonth)
                .lt("data", value: endOfMonth)
        }

        return try await query
            .order("data", ascending: true)
            .execute()
            .value
    }

    func createAttivita(attivita: Attivita.Create) async throws -> Attivita {
        try await client
            .from("attivita")
            .insert(attivita, returning: .representation)
            .select()
            .single()
            .execute()
            .value
    }

    func updateAttivita(id: UUID, attivita: Attivita.Update) async throws -> Attivita {
        try await client
            .from("attivita")
            .update(attivita, returning: .representation)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value
    }

    func markDone(id: UUID) async throws {
        struct DoneUpdate: Encodable { let done = true }
        try await client
            .from("attivita")
            .update(DoneUpdate(), returning: .minimal)
            .eq("id", value: id)
            .execute()
    }

    func setDone(id: UUID, done: Bool) async throws {
        struct DoneUpdate: Encodable { let done: Bool }
        try await client
            .from("attivita")
            .update(DoneUpdate(done: done), returning: .minimal)
            .eq("id", value: id)
            .execute()
    }

    func rescheduleAttivita(id: UUID, date: Date) async throws {
        struct DateUpdate: Encodable { let data: Date }
        try await client
            .from("attivita")
            .update(DateUpdate(data: date), returning: .minimal)
            .eq("id", value: id)
            .execute()
    }

    // MARK: - Catalogo / PlantKnowledge

    func fetchCatalogo() async throws -> [PlantKnowledge] {
        try await client
            .from("plant_knowledge")
            .select()
            .order("specie_nome", ascending: true)
            .execute()
            .value
    }

    func searchCatalogo(query: String) async throws -> [PlantKnowledge] {
        try await client
            .from("plant_knowledge")
            .select()
            .ilike("specie_nome", pattern: "%\(query)%")
            .order("specie_nome", ascending: true)
            .execute()
            .value
    }

    // MARK: - Forward Scheduling (Edge Function)

    struct ScheduleRequest: Encodable {
        let piantaId: UUID
        let dataSemina: String
        let growthDays: Int
        let activities: [ScheduledTemplateActivity]

        enum CodingKeys: String, CodingKey {
            case piantaId = "pianta_id"
            case dataSemina = "data_semina"
            case growthDays = "growth_days"
            case activities
        }
    }

    struct ScheduledTemplateActivity: Encodable {
        let nome: String
        let offsetDays: Int
        let recurrenceDays: Int?
        let color: String

        enum CodingKeys: String, CodingKey {
            case nome
            case offsetDays = "offset_days"
            case recurrenceDays = "recurrence_days"
            case color
        }
    }

    struct ScheduleResponse: Decodable {
        let message: String
        let count: Int
    }

    func scheduleActivities(
        piantaId: UUID,
        dataSemina: Date,
        growthDays: Int,
        activities: [ScheduledTemplateActivity]
    ) async throws -> ScheduleResponse {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dateStr = formatter.string(from: dataSemina)

        let request = ScheduleRequest(
            piantaId: piantaId,
            dataSemina: dateStr,
            growthDays: growthDays,
            activities: activities
        )

        return try await client.functions.invoke(
            "schedule-activities",
            options: FunctionInvokeOptions(body: request)
        )
    }
}

// MARK: - Errori

enum RepositoryError: LocalizedError {
    case invalidDate

    var errorDescription: String? {
        switch self {
        case .invalidDate:
            return "Impossibile calcolare l'intervallo di date per il filtro mensile."
        }
    }
}
