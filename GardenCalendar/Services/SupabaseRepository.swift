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
            let interno: Bool
            enum CodingKeys: String, CodingKey {
                case userId = "user_id"; case nome; case luogo; case latitudine; case longitudine; case interno
            }
        }
        return try await client
            .from("orti")
            .insert(Body(userId: userId, nome: orto.nome, luogo: orto.luogo, latitudine: orto.latitudine, longitudine: orto.longitudine, interno: orto.interno), returning: .representation)
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

    /// Carica una foto del giardino su Storage (bucket `plant-photos`) e ritorna l'URL pubblico.
    /// Path: `{userId}/orto-{ortoId}.jpg`, UUID minuscoli per coerenza con la policy RLS
    /// che confronta la cartella con `auth.uid()::text` (lowercase). Vedi uploadPlantPhoto.
    func uploadOrtoPhoto(ortoId: UUID, data: Data) async throws -> String {
        guard let userId = client.auth.currentSession?.user.id else {
            throw RepositoryError.notAuthenticated
        }
        let path = "\(userId.uuidString.lowercased())/orto-\(ortoId.uuidString.lowercased()).jpg"
        try await client.storage
            .from("plant-photos")
            .upload(
                path,
                data: data,
                options: FileOptions(contentType: "image/jpeg", upsert: true)
            )
        return try client.storage
            .from("plant-photos")
            .getPublicURL(path: path)
            .absoluteString
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
        guard !orti.isEmpty else { return [] }
        return try await client
            .from("piante_coltivate")
            .select()
            .in("orto_id", values: orti.map(\.id))
            .order("created_at", ascending: true)
            .execute()
            .value
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

    /// Carica una foto pianta su Storage (bucket `plant-photos`) e ritorna l'URL pubblico.
    /// Path: `{userId}/{piantaId}.jpg` per coerenza con le policy RLS.
    /// UUID minuscoli: la policy storage confronta con `auth.uid()::text` (lowercase),
    /// mentre `UUID.uuidString` è maiuscolo → mismatch = RLS 42501.
    func uploadPlantPhoto(piantaId: UUID, data: Data) async throws -> String {
        guard let userId = client.auth.currentSession?.user.id else {
            throw RepositoryError.notAuthenticated
        }
        let path = "\(userId.uuidString.lowercased())/\(piantaId.uuidString.lowercased()).jpg"
        try await client.storage
            .from("plant-photos")
            .upload(
                path,
                data: data,
                options: FileOptions(contentType: "image/jpeg", upsert: true)
            )
        return try client.storage
            .from("plant-photos")
            .getPublicURL(path: path)
            .absoluteString
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

    /// Marca un'attività ricorrente come completata e riprogramma la prossima occorrenza
    /// a partire da oggi (data reale di completamento) invece che dalla data originaria schedulata.
    /// Se l'attività completata è nel futuro (pianificazione anticipata), la prossima occorrenza
    /// parte dalla sua data anziché da oggi, per evitare che ricada sullo stesso giorno appena completato.
    func completeActivity(_ activity: Attivita) async throws {
        try await setDone(id: activity.id, done: true)

        let today = Calendar.current.startOfDay(for: Date())
        let activityDay = Calendar.current.startOfDay(for: activity.data)
        let basis = max(today, activityDay)

        guard let recurrenceDays = activity.recurrenceDays, recurrenceDays > 0,
              let newDate = Calendar.current.date(byAdding: .day, value: recurrenceDays, to: basis)
        else { return }

        if let next = try await fetchNextIrrigation(piantaId: activity.piantaId, nome: activity.nome, after: activity.data) {
            try await rescheduleAttivita(id: next.id, date: newDate)
        }
    }

    func rescheduleAttivita(id: UUID, date: Date) async throws {
        struct DateUpdate: Encodable { let data: Date }
        try await client
            .from("attivita")
            .update(DateUpdate(data: date), returning: .minimal)
            .eq("id", value: id)
            .execute()
    }

    // MARK: - Raccolti

    func fetchRaccolti(piantaId: UUID) async throws -> [Raccolto] {
        try await client
            .from("raccolti")
            .select()
            .eq("pianta_id", value: piantaId)
            .order("data", ascending: false)
            .execute()
            .value
    }

    func createRaccolto(_ raccolto: RaccoltoCreate) async throws -> Raccolto {
        try await client
            .from("raccolti")
            .insert(raccolto, returning: .representation)
            .select()
            .single()
            .execute()
            .value
    }

    func deleteRaccolto(id: UUID) async throws {
        try await client
            .from("raccolti")
            .delete()
            .eq("id", value: id)
            .execute()
    }

    func fetchNextIrrigation(piantaId: UUID, nome: String, after: Date) async throws -> Attivita? {
        let results: [Attivita] = try await client
            .from("attivita")
            .select()
            .eq("pianta_id", value: piantaId)
            .eq("nome", value: nome)
            .gt("data", value: after)
            .eq("done", value: false)
            .order("data", ascending: true)
            .limit(1)
            .execute()
            .value
        return results.first
    }

    func markRainAbsorbed(id: UUID) async throws {
        struct RainAbsorbedUpdate: Encodable {
            let rainAdjusted = true
            let rainRescheduled = true
            enum CodingKeys: String, CodingKey {
                case rainAdjusted = "rain_adjusted"
                case rainRescheduled = "rain_rescheduled"
            }
        }
        try await client
            .from("attivita")
            .update(RainAbsorbedUpdate(), returning: .minimal)
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

    func fetchPianta(id: UUID) async throws -> PiantaColtivata {
        try await client
            .from("piante_coltivate")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    func fetchPlantKnowledge(id: UUID) async throws -> PlantKnowledge {
        try await client
            .from("plant_knowledge")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    // MARK: - Activity Overrides

    func updateActivityOverrides(piantaId: UUID, overrides: [PiantaColtivata.ActivityOverride]) async throws {
        struct OverrideUpdate: Encodable {
            let activityOverrides: [PiantaColtivata.ActivityOverride]
            enum CodingKeys: String, CodingKey { case activityOverrides = "activity_overrides" }
        }
        try await client
            .from("piante_coltivate")
            .update(OverrideUpdate(activityOverrides: overrides), returning: .minimal)
            .eq("id", value: piantaId)
            .execute()
    }

    func rescheduleActivity(
        piantaId: UUID,
        dataSemina: Date,
        growthDays: Int,
        activity: ScheduledTemplateActivity
    ) async throws {
        let today = Calendar.current.startOfDay(for: Date())

        // Cancella occorrenze future non completate per questo tipo di attività
        try await client
            .from("attivita")
            .delete()
            .eq("pianta_id", value: piantaId)
            .eq("nome", value: activity.nome)
            .eq("done", value: false)
            .gte("data", value: today)
            .execute()

        // Genera nuove occorrenze (replica logica Edge Function per singola attività)
        let plantLifespan = max(growthDays, 30)
        guard let endDate = Calendar.current.date(byAdding: .day, value: plantLifespan, to: dataSemina),
              let baseDate = Calendar.current.date(byAdding: .day, value: activity.offsetDays, to: dataSemina) else {
            throw RepositoryError.invalidDate
        }

        var toInsert: [Attivita.Create] = []

        if let recurrenceDays = activity.recurrenceDays, recurrenceDays > 0 {
            var occurrence = baseDate
            while occurrence <= endDate {
                if occurrence >= today {
                    toInsert.append(Attivita.Create(
                        piantaId: piantaId,
                        nome: activity.nome,
                        data: occurrence,
                        done: false,
                        rainAdjusted: false,
                        rainRescheduled: false,
                        userEvent: false,
                        sourceAction: "override",
                        note: nil,
                        color: activity.color,
                        recurrenceDays: recurrenceDays
                    ))
                }
                guard let next = Calendar.current.date(byAdding: .day, value: recurrenceDays, to: occurrence) else {
                    throw RepositoryError.invalidDate
                }
                occurrence = next
            }
        } else if activity.offsetDays <= plantLifespan && baseDate >= today {
            toInsert.append(Attivita.Create(
                piantaId: piantaId,
                nome: activity.nome,
                data: baseDate,
                done: false,
                rainAdjusted: false,
                rainRescheduled: false,
                userEvent: false,
                sourceAction: "override",
                note: nil,
                color: activity.color,
                recurrenceDays: nil
            ))
        }

        guard !toInsert.isEmpty else { return }
        try await client
            .from("attivita")
            .insert(toInsert, returning: .minimal)
            .execute()
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
        formatter.timeZone = .current
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

    // MARK: - Diagnosi pianta (LLM vision)

    struct DiagnoseRequest: Encodable {
        let piantaId: UUID
        let imageBase64: String

        enum CodingKeys: String, CodingKey {
            case piantaId = "pianta_id"
            case imageBase64 = "image_base64"
        }
    }

    struct DiagnoseResponse: Decodable {
        let diagnosis: String
    }

    func diagnosePlant(piantaId: UUID, imageBase64: String) async throws -> DiagnoseResponse {
        let request = DiagnoseRequest(piantaId: piantaId, imageBase64: imageBase64)
        return try await client.functions.invoke(
            "diagnose-plant",
            options: FunctionInvokeOptions(body: request)
        )
    }
}

// MARK: - Errori

enum RepositoryError: LocalizedError {
    case invalidDate
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .invalidDate:
            return "Impossibile calcolare l'intervallo di date per il filtro mensile."
        case .notAuthenticated:
            return "Utente non autenticato."
        }
    }
}
