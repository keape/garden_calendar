import Foundation
import Observation

@Observable
@MainActor
final class PlantCatalogService {
    static let shared = PlantCatalogService()

    private(set) var localResults: [PlantKnowledge] = []
    private(set) var externalResults: [PlantKnowledge] = []
    private(set) var isSearchingExternal = false

    private var perenualCache: [String: [PlantKnowledge]] = [:]
    private let perenual = PerenualAPIClient()

    private init() {}

    func search(query: String, in repository: SupabaseRepository) async {
        localResults = []
        externalResults = []

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        // 1. Ricerca locale Supabase
        localResults = (try? await repository.searchCatalogo(query: query)) ?? []

        // 2. Fallback Perenual se risultati locali < 3
        if localResults.count < 3 {
            await fetchExternal(query: query)
        }
    }

    func loadAll(from repository: SupabaseRepository) async {
        localResults = (try? await repository.fetchCatalogo()) ?? []
        externalResults = []
    }

    private func fetchExternal(query: String) async {
        let cacheKey = query.lowercased()
        if let cached = perenualCache[cacheKey] {
            externalResults = cached.filter { ext in
                !localResults.contains { $0.specieNome.localizedCaseInsensitiveCompare(ext.specieNome) == .orderedSame }
            }
            return
        }

        isSearchingExternal = true
        defer { isSearchingExternal = false }

        let fetched = (try? await perenual.search(query)) ?? []
        perenualCache[cacheKey] = fetched
        externalResults = fetched.filter { ext in
            !localResults.contains { $0.specieNome.localizedCaseInsensitiveCompare(ext.specieNome) == .orderedSame }
        }
    }

    // Controlla se una PlantKnowledge viene da Perenual (non ha UUID reale)
    func isExternalSource(_ knowledge: PlantKnowledge) -> Bool {
        knowledge.slug.hasPrefix("perenual-")
    }
}
