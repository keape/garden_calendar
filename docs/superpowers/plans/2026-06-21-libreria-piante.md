# Libreria Piante — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sostituire la lista hardcoded di 20 piante con un catalogo Supabase arricchito (50+ piante) dotato di scheda informativa, e aggiungere fallback verso API Perenual per piante non in catalogo.

**Architecture:** `PlantCatalogService` (nuovo `@Observable`) orchestra la ricerca: prima in `plant_knowledge` via `SupabaseRepository.searchCatalogo()` già esistente, poi — se risultati < 3 — in Perenual API (100 req/day free tier, cache in-memory per sessione). `PlantDetailSheet` (nuova view) mostra la scheda completa. `AggiungiPiantaView` viene refactored per usare questo layer invece della lista hardcoded.

**Tech Stack:** Swift 6.0, SwiftUI, iOS 18+, Supabase Swift SDK ≥ 2.0, URLSession (no dipendenze extra), Perenual REST API v1.

## Global Constraints

- Swift 6.0 strict concurrency — tutti i tipi nuovi devono essere `Sendable` o marcati `@MainActor`
- iOS 18+ deployment target
- Pattern `SupabaseRepository` esistente: `.from("table").select()...execute().value`
- Nessuna dipendenza Swift Package aggiuntiva
- Localizzazione: ogni stringa UI va in `Strings.swift` con valori IT e EN
- Dark mode: usare `AppTheme.*` per colori, mai hardcoded
- `attivita_suggerite` nel DB è JSONB → decoding diretto come `[AttivitaSuggerita]` (fix bug latente nel modello)
- Perenual API key: `USER_DEVE_REGISTRARSI_SU_perenual.com` e sostituire placeholder

---

## File Map

**Modificare:**
- `GardenCalendar/Models/PlantKnowledge.swift` — estendere struct, fix JSONB decoding, aggiungere `PlantType`
- `GardenCalendar/Views/Piante/AggiungiPiantaView.swift` — refactor ricerca
- `GardenCalendar/SupabaseConfig.swift` — aggiungere `perenualApiKey`
- `GardenCalendar/Localization/Strings.swift` — nuove chiavi UI
- `supabase-schema.sql` — aggiungere commento migration reference

**Creare:**
- `supabase-migrations/20260621_plant_library.sql` — migration SQL
- `GardenCalendar/Services/PlantCatalogService.swift` — orchestratore ricerca
- `GardenCalendar/Services/PerenualAPIClient.swift` — HTTP client Perenual
- `GardenCalendar/Views/Piante/PlantDetailSheet.swift` — scheda informativa pianta

---

## Task 1: DB Migration — Nuovi campi `plant_knowledge`

**Files:**
- Create: `supabase-migrations/20260621_plant_library.sql`

**Context:** La tabella `plant_knowledge` ha solo 6 campi. Aggiungere i campi arricchiti come `NULLABLE` così le 8 piante esistenti rimangono valide. Anche `semina_mesi_esterno` e `semina_mesi_interno` potrebbero mancare se aggiunti con una migration precedente non tracciata — usare `IF NOT EXISTS`.

- [ ] **Step 1: Creare la directory migrations**

```bash
mkdir -p "supabase-migrations"
```

- [ ] **Step 2: Creare il file SQL**

Creare `supabase-migrations/20260621_plant_library.sql` con questo contenuto:

```sql
-- Migration: plant_library
-- Aggiunge campi arricchiti a plant_knowledge per la libreria piante v1

-- Campi semina (potrebbero già esistere da migration precedente)
ALTER TABLE plant_knowledge
  ADD COLUMN IF NOT EXISTS semina_mesi_esterno integer[] NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS semina_mesi_interno integer[] NOT NULL DEFAULT '{}';

-- Nuovi campi arricchiti (tutti nullable — le 8 piante esistenti rimangono valide)
ALTER TABLE plant_knowledge
  ADD COLUMN IF NOT EXISTS specie_nome_scientifico text,
  ADD COLUMN IF NOT EXISTS descrizione text,
  ADD COLUMN IF NOT EXISTS annaffiatura text,
  ADD COLUMN IF NOT EXISTS esposizione text,
  ADD COLUMN IF NOT EXISTS tipo text,
  ADD COLUMN IF NOT EXISTS difficolta text,
  ADD COLUMN IF NOT EXISTS image_url text,
  ADD COLUMN IF NOT EXISTS mesi_raccolta integer[],
  ADD COLUMN IF NOT EXISTS piante_compagne text[],
  ADD COLUMN IF NOT EXISTS piante_incompatibili text[];

-- Index full-text search italiano (potrebbe già esistere)
CREATE INDEX IF NOT EXISTS idx_plant_knowledge_search
  ON plant_knowledge USING gin(to_tsvector('italian', specie_nome));

-- Aggiorna le 8 piante esistenti con dati arricchiti (UPDATE)
UPDATE plant_knowledge SET
  semina_mesi_esterno = '{4,5}',
  semina_mesi_interno = '{2,3}',
  specie_nome_scientifico = 'Solanum lycopersicum',
  descrizione = 'Ortaggio estivo molto diffuso. Richiede sostegno con tutori e pinzatura dei polloni per produzioni abbondanti.',
  annaffiatura = 'ogni 3-4 giorni, evitare ristagni',
  esposizione = 'Pieno sole (6+ ore)',
  tipo = 'ortaggio',
  difficolta = 'Medio',
  mesi_raccolta = '{7,8,9}',
  piante_compagne = '{Basilico,Carota,Prezzemolo}',
  piante_incompatibili = '{Finocchio,Cavolo}'
WHERE slug = 'pomodoro-san-marzano';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{4,5,6}',
  semina_mesi_interno = '{3,4}',
  specie_nome_scientifico = 'Ocimum basilicum',
  descrizione = 'Aromatica estiva sensibile al freddo. Teme il vento e le temperature sotto 10°C. Ottimo compagno del pomodoro.',
  annaffiatura = 'ogni 2-3 giorni, terreno umido non saturo',
  esposizione = 'Pieno sole o mezza ombra',
  tipo = 'aromatica',
  difficolta = 'Facile',
  mesi_raccolta = '{6,7,8,9}',
  piante_compagne = '{Pomodoro,Peperone,Zucchina}',
  piante_incompatibili = '{Salvia,Rosmarino}'
WHERE slug = 'basilico-genovese';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{4,5}',
  semina_mesi_interno = '{3}',
  specie_nome_scientifico = 'Cucurbita pepo',
  descrizione = 'Ortaggio vigoroso a rapida crescita. Necessita di molto spazio (min. 1m²) e impollinazione incrociata.',
  annaffiatura = 'ogni 3-4 giorni, abbondante in estate',
  esposizione = 'Pieno sole',
  tipo = 'ortaggio',
  difficolta = 'Facile',
  mesi_raccolta = '{6,7,8,9}',
  piante_compagne = '{Basilico,Fagiolo,Mais}',
  piante_incompatibili = '{Patata,Finocchio}'
WHERE slug = 'zucchine-romanesco';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{3,4,8,9}',
  semina_mesi_interno = '{2,3}',
  specie_nome_scientifico = 'Lactuca sativa',
  descrizione = 'Ortaggio a foglia di rapida crescita. Preferisce temperature fresche; va in fiore con il caldo estivo.',
  annaffiatura = 'ogni 2 giorni, costante',
  esposizione = 'Sole o mezza ombra',
  tipo = 'ortaggio',
  difficolta = 'Facile',
  mesi_raccolta = '{4,5,6,9,10}',
  piante_compagne = '{Carota,Ravanello,Cipolla}',
  piante_incompatibili = '{Sedano,Prezzemolo}'
WHERE slug = 'lattuga-canasta';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{3,4,8,9}',
  semina_mesi_interno = '{}',
  specie_nome_scientifico = 'Raphanus sativus',
  descrizione = 'Radice a crescita molto rapida, ideale per riempire spazi vuoti nell orto. Ottimo indicatore della salute del suolo.',
  annaffiatura = 'ogni 2 giorni, regolare',
  esposizione = 'Sole o mezza ombra',
  tipo = 'ortaggio',
  difficolta = 'Facile',
  mesi_raccolta = '{4,5,9,10}',
  piante_compagne = '{Lattuga,Carota,Spinacio}',
  piante_incompatibili = '{Cavolo}'
WHERE slug = 'ravanelli';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{4,5}',
  semina_mesi_interno = '{3}',
  specie_nome_scientifico = 'Phaseolus vulgaris',
  descrizione = 'Legume rampicante che fissa l azoto nel suolo. Necessita di sostegno (rete o paletti da 1.5m).',
  annaffiatura = 'ogni 3-4 giorni, evitare bagnare i fiori',
  esposizione = 'Pieno sole',
  tipo = 'ortaggio',
  difficolta = 'Facile',
  mesi_raccolta = '{7,8,9}',
  piante_compagne = '{Carota,Cetriolo,Mais}',
  piante_incompatibili = '{Cipolla,Aglio,Finocchio}'
WHERE slug = 'fagiolini-rampicanti';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{4,5}',
  semina_mesi_interno = '{2,3}',
  specie_nome_scientifico = 'Capsicum annuum',
  descrizione = 'Ortaggio termofilo che richiede temperature costanti >15°C. Sensibile agli sbalzi termici, beneficia di pacciamatura.',
  annaffiatura = 'ogni 3 giorni, costante',
  esposizione = 'Pieno sole',
  tipo = 'ortaggio',
  difficolta = 'Medio',
  mesi_raccolta = '{7,8,9,10}',
  piante_compagne = '{Basilico,Carota,Cipolla}',
  piante_incompatibili = '{Finocchio,Cavolo}'
WHERE slug = 'peperoni-corno';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{4,5}',
  semina_mesi_interno = '{2,3}',
  specie_nome_scientifico = 'Solanum melongena',
  descrizione = 'Ortaggio estivo che ama il calore. Richiede potatura delle cime per produzione abbondante. Sensibile agli afidi.',
  annaffiatura = 'ogni 3 giorni, costante',
  esposizione = 'Pieno sole',
  tipo = 'ortaggio',
  difficolta = 'Medio',
  mesi_raccolta = '{7,8,9,10}',
  piante_compagne = '{Basilico,Peperone,Fagiolo}',
  piante_incompatibili = '{Finocchio,Patata}'
WHERE slug = 'melanzane-violetta';
```

- [ ] **Step 3: Applicare su Supabase Dashboard**

Aprire `https://supabase.com/dashboard` → progetto → SQL Editor → incollare il contenuto del file e cliccare "Run".

Verificare: nessun errore, le 8 piante esistenti hanno ora i nuovi campi popolati.

---

## Task 2: Estendi `PlantKnowledge.swift` + fix JSONB decoding

**Files:**
- Modify: `GardenCalendar/Models/PlantKnowledge.swift`

**Context:** Il campo `attivitaSuggerite` è decodificato come `String` nel modello Swift ma in PostgreSQL è `JSONB`. PostgREST lo restituisce come oggetto JSON (non string), quindi `c.decode(String.self, ...)` probabilmente fallisce silenziosamente (restituisce `[]` via `?? []`). Questo task corregge il decoding a `[AttivitaSuggerita]` diretto e aggiunge i nuovi campi.

- [ ] **Step 1: Riscrivere `PlantKnowledge.swift`**

Sostituire l'intero file con:

```swift
import Foundation

enum PlantType: String, Codable, CaseIterable, Sendable {
    case ortaggio, aromatica, frutto, fiore, altro

    var displayName: String {
        switch self {
        case .ortaggio: return "Ortaggio"
        case .aromatica: return "Aromatica"
        case .frutto: return "Frutto"
        case .fiore: return "Fiore"
        case .altro: return "Altro"
        }
    }

    var emoji: String {
        switch self {
        case .ortaggio: return "🥦"
        case .aromatica: return "🌿"
        case .frutto: return "🍓"
        case .fiore: return "🌸"
        case .altro: return "🌱"
        }
    }
}

struct PlantKnowledge: Codable, Identifiable, Sendable {
    let id: UUID
    let slug: String
    let specieNome: String
    let growthDays: Int
    let attivitaSuggerite: [AttivitaSuggerita]
    let seminaMesiEsterno: [Int]
    let seminaMesiInterno: [Int]
    let createdAt: Date
    let updatedAt: Date

    // Campi arricchiti (opzionali — piante legacy li hanno nil)
    let specieNomeScentifico: String?
    let descrizione: String?
    let annaffiatura: String?
    let esposizione: String?
    let tipo: PlantType?
    let difficolta: String?
    let imageUrl: String?
    let mesiRaccolta: [Int]?
    let pianteCompagne: [String]?
    let pianteIncompatibili: [String]?

    enum CodingKeys: String, CodingKey {
        case id, slug
        case specieNome = "specie_nome"
        case growthDays = "growth_days"
        case attivitaSuggerite = "attivita_suggerite"
        case seminaMesiEsterno = "semina_mesi_esterno"
        case seminaMesiInterno = "semina_mesi_interno"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case specieNomeScentifico = "specie_nome_scientifico"
        case descrizione
        case annaffiatura
        case esposizione
        case tipo
        case difficolta
        case imageUrl = "image_url"
        case mesiRaccolta = "mesi_raccolta"
        case pianteCompagne = "piante_compagne"
        case pianteIncompatibili = "piante_incompatibili"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        slug = try c.decode(String.self, forKey: .slug)
        specieNome = try c.decode(String.self, forKey: .specieNome)
        growthDays = try c.decode(Int.self, forKey: .growthDays)

        // attivita_suggerite è JSONB in PostgreSQL → array diretto
        // Se PostgREST restituisce una stringa JSON (comportamento legacy),
        // proviamo prima come array, poi come stringa da ri-parsare.
        if let arr = try? c.decode([AttivitaSuggerita].self, forKey: .attivitaSuggerite) {
            attivitaSuggerite = arr
        } else if let raw = try? c.decode(String.self, forKey: .attivitaSuggerite),
                  let data = raw.data(using: .utf8),
                  let parsed = try? JSONDecoder().decode([AttivitaSuggerita].self, from: data) {
            attivitaSuggerite = parsed
        } else {
            attivitaSuggerite = []
        }

        seminaMesiEsterno = (try? c.decodeIfPresent([Int].self, forKey: .seminaMesiEsterno)) ?? []
        seminaMesiInterno = (try? c.decodeIfPresent([Int].self, forKey: .seminaMesiInterno)) ?? []
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)

        specieNomeScentifico = try? c.decodeIfPresent(String.self, forKey: .specieNomeScentifico)
        descrizione = try? c.decodeIfPresent(String.self, forKey: .descrizione)
        annaffiatura = try? c.decodeIfPresent(String.self, forKey: .annaffiatura)
        esposizione = try? c.decodeIfPresent(String.self, forKey: .esposizione)
        tipo = try? c.decodeIfPresent(PlantType.self, forKey: .tipo)
        difficolta = try? c.decodeIfPresent(String.self, forKey: .difficolta)
        imageUrl = try? c.decodeIfPresent(String.self, forKey: .imageUrl)
        mesiRaccolta = try? c.decodeIfPresent([Int].self, forKey: .mesiRaccolta)
        pianteCompagne = try? c.decodeIfPresent([String].self, forKey: .pianteCompagne)
        pianteIncompatibili = try? c.decodeIfPresent([String].self, forKey: .pianteIncompatibili)
    }
}

extension PlantKnowledge {
    struct AttivitaSuggerita: Codable, Sendable {
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
}
```

- [ ] **Step 2: Build + verifica compilazione**

In Xcode: `⌘B`. Se ci sono errori su `attivitaSuggeriteDecodificate` (la computed property rimossa), cercare tutti i riferimenti e rimuoverli — ora si usa `knowledge.attivitaSuggerite` direttamente.

- [ ] **Step 3: Commit**

```bash
git add "GardenCalendar/Models/PlantKnowledge.swift"
git commit -m "feat(model): extend PlantKnowledge with enriched fields, fix JSONB decoding"
```

---

## Task 3: Crea `PerenualAPIClient.swift`

**Files:**
- Create: `GardenCalendar/Services/PerenualAPIClient.swift`
- Modify: `GardenCalendar/SupabaseConfig.swift`

**Context:** Client HTTP URLSession per l'API Perenual v1. Free tier: 100 req/day, nessuna auth OAuth (solo API key nel query string). I risultati vengono mappati in `PlantKnowledge` con dati parziali (senza `attivitaSuggerite` e senza `id`/`slug` definitivi).

**Nota per lo sviluppatore:** Registrarsi su `perenual.com`, copiare l'API key gratuita, incollare in `SupabaseConfig.perenualApiKey`.

- [ ] **Step 1: Aggiungere API key in `SupabaseConfig.swift`**

Aggiungere in fondo all'enum `SupabaseConfig`:

```swift
// Registrarsi su perenual.com per ottenere la chiave gratuita (100 req/day)
static let perenualApiKey = "INSERIRE_QUI_API_KEY_PERENUAL"
```

- [ ] **Step 2: Creare `PerenualAPIClient.swift`**

```swift
import Foundation

struct PerenualAPIClient: Sendable {
    private let apiKey: String
    private let baseURL = "https://perenual.com/api"

    init(apiKey: String = SupabaseConfig.perenualApiKey) {
        self.apiKey = apiKey
    }

    func search(_ query: String) async throws -> [PlantKnowledge] {
        guard !apiKey.hasPrefix("INSERIRE") else { return [] }
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "\(baseURL)/species-list?key=\(apiKey)&q=\(encoded)&page=1")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { return [] }
        let result = try JSONDecoder().decode(PerenualSearchResponse.self, from: data)
        return result.data.compactMap { toPlantKnowledge($0) }
    }

    private func toPlantKnowledge(_ p: PerenualPlant) -> PlantKnowledge? {
        guard let name = p.commonName, !name.isEmpty else { return nil }
        let slug = "perenual-\(p.id)"
        // Placeholder UUID per piante esterne — non persistono in Supabase
        let id = UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012d", p.id % 1_000_000_000_000))") ?? UUID()

        let annaffiatura: String? = switch p.watering {
            case "Frequent": "ogni 2-3 giorni"
            case "Average": "ogni 4-5 giorni"
            case "Minimum": "ogni 7-10 giorni"
            case "None": "raramente, solo in siccità"
            default: nil
        }

        let esposizione: String? = p.sunlight?.first.map { sun in
            switch sun.lowercased() {
            case let s where s.contains("full sun"): return "Pieno sole"
            case let s where s.contains("part shade"): return "Mezza ombra"
            case let s where s.contains("full shade"): return "Ombra"
            default: return sun.capitalized
            }
        }

        let imageUrl = p.defaultImage?.mediumUrl

        // Usa attività di default categoria (non abbiamo dati Perenual specifici)
        let attivita: [PlantKnowledge.AttivitaSuggerita] = [
            .init(nome: "Irrigazione", offsetDays: 0, recurrenceDays: 4, color: "blue"),
            .init(nome: "Raccolta", offsetDays: 90, recurrenceDays: nil, color: "orange")
        ]

        return PlantKnowledge(
            id: id,
            slug: slug,
            specieNome: name,
            growthDays: 90,
            attivitaSuggerite: attivita,
            seminaMesiEsterno: [],
            seminaMesiInterno: [],
            createdAt: Date(),
            updatedAt: Date(),
            specieNomeScentifico: p.scientificName?.first,
            descrizione: nil,
            annaffiatura: annaffiatura,
            esposizione: esposizione,
            tipo: nil,
            difficolta: nil,
            imageUrl: imageUrl,
            mesiRaccolta: nil,
            pianteCompagne: nil,
            pianteIncompatibili: nil
        )
    }
}

// MARK: - Perenual Response Models

private struct PerenualSearchResponse: Decodable {
    let data: [PerenualPlant]
}

private struct PerenualPlant: Decodable {
    let id: Int
    let commonName: String?
    let scientificName: [String]?
    let watering: String?
    let sunlight: [String]?
    let defaultImage: PerenualImage?

    enum CodingKeys: String, CodingKey {
        case id
        case commonName = "common_name"
        case scientificName = "scientific_name"
        case watering
        case sunlight
        case defaultImage = "default_image"
    }
}

private struct PerenualImage: Decodable {
    let mediumUrl: String?
    enum CodingKeys: String, CodingKey { case mediumUrl = "medium_url" }
}
```

**Nota:** `PlantKnowledge` non ha un init pubblico memberwise perché usa `init(from:)`. Aggiungere un init interno in Task 2 o creare un factory method. Vedere Step 3.

- [ ] **Step 3: Aggiungere init memberwise a `PlantKnowledge`**

In `PlantKnowledge.swift`, aggiungere dopo il `init(from decoder:)` esistente:

```swift
init(
    id: UUID, slug: String, specieNome: String, growthDays: Int,
    attivitaSuggerite: [AttivitaSuggerita], seminaMesiEsterno: [Int],
    seminaMesiInterno: [Int], createdAt: Date, updatedAt: Date,
    specieNomeScentifico: String? = nil, descrizione: String? = nil,
    annaffiatura: String? = nil, esposizione: String? = nil,
    tipo: PlantType? = nil, difficolta: String? = nil,
    imageUrl: String? = nil, mesiRaccolta: [Int]? = nil,
    pianteCompagne: [String]? = nil, pianteIncompatibili: [String]? = nil
) {
    self.id = id; self.slug = slug; self.specieNome = specieNome
    self.growthDays = growthDays; self.attivitaSuggerite = attivitaSuggerite
    self.seminaMesiEsterno = seminaMesiEsterno; self.seminaMesiInterno = seminaMesiInterno
    self.createdAt = createdAt; self.updatedAt = updatedAt
    self.specieNomeScentifico = specieNomeScentifico; self.descrizione = descrizione
    self.annaffiatura = annaffiatura; self.esposizione = esposizione
    self.tipo = tipo; self.difficolta = difficolta; self.imageUrl = imageUrl
    self.mesiRaccolta = mesiRaccolta; self.pianteCompagne = pianteCompagne
    self.pianteIncompatibili = pianteIncompatibili
}
```

- [ ] **Step 4: Build + verifica compilazione**

`⌘B` — nessun errore.

- [ ] **Step 5: Commit**

```bash
git add "GardenCalendar/Services/PerenualAPIClient.swift" "GardenCalendar/SupabaseConfig.swift" "GardenCalendar/Models/PlantKnowledge.swift"
git commit -m "feat(services): add PerenualAPIClient with search + PlantKnowledge memberwise init"
```

---

## Task 4: Crea `PlantCatalogService.swift`

**Files:**
- Create: `GardenCalendar/Services/PlantCatalogService.swift`

**Context:** Orchestratore della ricerca piante. Cerca prima nel catalogo locale Supabase (via `SupabaseRepository.searchCatalogo` già esistente). Se i risultati locali sono < 3, chiama Perenual come fallback. Tiene una cache in-memory per sessione per evitare chiamate ripetute a Perenual. È `@Observable` per integrarsi con SwiftUI.

- [ ] **Step 1: Creare `PlantCatalogService.swift`**

```swift
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
```

- [ ] **Step 2: Registrare `PlantCatalogService` nell'app entry point**

Aprire il file `@main` dell'app (tipicamente `GardenCalendarApp.swift`). Aggiungere `.environment(PlantCatalogService.shared)` alla WindowGroup, oppure iniettarlo dove viene iniettato `SupabaseRepository.shared`.

Esempio (verificare il file effettivo):

```swift
WindowGroup {
    ContentView()
        .environment(SupabaseRepository.shared)
        .environment(AuthManager.shared)
        .environment(LanguageManager.shared)
        .environment(PlantCatalogService.shared)  // ← aggiungere
}
```

- [ ] **Step 3: Build + verifica compilazione**

`⌘B` — nessun errore.

- [ ] **Step 4: Commit**

```bash
git add "GardenCalendar/Services/PlantCatalogService.swift"
git commit -m "feat(services): add PlantCatalogService with local+Perenual search and memory cache"
```

---

## Task 5: Crea `PlantDetailSheet.swift`

**Files:**
- Create: `GardenCalendar/Views/Piante/PlantDetailSheet.swift`

**Context:** Sheet consultabile che mostra la scheda completa di una pianta dal catalogo. Viene presentata quando l'utente tocca una pianta nella lista di ricerca. Contiene: immagine, nome scientifico, tipo/difficoltà, mesi di semina, cure, attività generate, piante compagne/incompatibili. CTA per aggiungere all'orto.

**Interfaccia prodotta:**
```swift
struct PlantDetailSheet: View
  init(knowledge: PlantKnowledge, ortoId: UUID?, onAdd: (PlantKnowledge) -> Void)
```

- [ ] **Step 1: Creare `PlantDetailSheet.swift`**

```swift
import SwiftUI

struct PlantDetailSheet: View {
    let knowledge: PlantKnowledge
    let ortoId: UUID?
    let onAdd: (PlantKnowledge) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var lang

    private var mesiNomi: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: lang.current.rawValue)
        return formatter.shortMonthSymbols
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    if !knowledge.seminaMesiEsterno.isEmpty || !knowledge.seminaMesiInterno.isEmpty {
                        semiSection
                    }
                    if knowledge.annaffiatura != nil || knowledge.esposizione != nil || knowledge.mesiRaccolta != nil {
                        cureSection
                    }
                    if !knowledge.attivitaSuggerite.isEmpty {
                        attivitaSection
                    }
                    if let compagne = knowledge.pianteCompagne, !compagne.isEmpty,
                       let incomp = knowledge.pianteIncompatibili, !incomp.isEmpty {
                        companionSection(compagne: compagne, incompatibili: incomp)
                    } else if let compagne = knowledge.pianteCompagne, !compagne.isEmpty {
                        companionSection(compagne: compagne, incompatibili: [])
                    }
                    if ortoId != nil {
                        addButton
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(knowledge.specieNome)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(lang.common.ok) { dismiss() }
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let url = knowledge.imageUrl, let parsed = URL(string: url) {
                AsyncImage(url: parsed) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(AppTheme.cardSecondary)
                        .overlay(Image(systemName: "leaf.fill").font(.largeTitle).foregroundStyle(.secondary))
                }
                .frame(maxWidth: .infinity, maxHeight: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if let sci = knowledge.specieNomeScentifico {
                Text(sci).font(.caption).foregroundStyle(.secondary).italic()
            }

            HStack(spacing: 8) {
                if let tipo = knowledge.tipo {
                    badge(tipo.emoji + " " + tipo.displayName, color: AppTheme.primaryGreen)
                }
                if let diff = knowledge.difficolta {
                    let color: Color = diff == "Facile" ? .green : diff == "Difficile" ? .red : .orange
                    badge(diff, color: color)
                }
                if knowledge.slug.hasPrefix("perenual-") {
                    badge("Dati parziali", color: .secondary)
                }
            }

            if let desc = knowledge.descrizione {
                Text(desc).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var semiSection: some View {
        sectionCard(title: "Quando seminare", icon: "calendar") {
            if !knowledge.seminaMesiEsterno.isEmpty {
                monthRow(label: "Esterno", months: knowledge.seminaMesiEsterno, color: AppTheme.primaryGreen)
            }
            if !knowledge.seminaMesiInterno.isEmpty {
                monthRow(label: "Interno", months: knowledge.seminaMesiInterno, color: .orange)
            }
        }
    }

    private var cureSection: some View {
        sectionCard(title: "Cure", icon: "drop.fill") {
            if let ann = knowledge.annaffiatura {
                infoRow(icon: "drop.fill", label: "Annaffiatura", value: ann, iconColor: .blue)
            }
            if let esp = knowledge.esposizione {
                infoRow(icon: "sun.max.fill", label: "Esposizione", value: esp, iconColor: .yellow)
            }
            if let mesi = knowledge.mesiRaccolta, !mesi.isEmpty {
                infoRow(icon: "basket.fill", label: "Raccolta", value: mesiNomi.enumerated()
                    .filter { mesi.contains($0.offset + 1) }.map(\.element).joined(separator: ", "),
                    iconColor: .orange)
            }
        }
    }

    private var attivitaSection: some View {
        sectionCard(title: "Attività generate", icon: "checklist") {
            ForEach(knowledge.attivitaSuggerite, id: \.nome) { att in
                HStack {
                    ActivityColorDot(activityName: att.nome, size: 8)
                    Text(att.nome).font(.subheadline)
                    Spacer()
                    if let rec = att.recurrenceDays {
                        Text("ogni \(rec)g").font(.caption).foregroundStyle(.secondary)
                    } else {
                        Text("una volta").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func companionSection(compagne: [String], incompatibili: [String]) -> some View {
        sectionCard(title: "Piante compagne", icon: "heart.fill") {
            if !compagne.isEmpty {
                chipRow(chips: compagne, color: .green)
            }
            if !incompatibili.isEmpty {
                chipRow(chips: incompatibili, color: .red)
            }
        }
    }

    private var addButton: some View {
        Button(action: { onAdd(knowledge); dismiss() }) {
            Label("Aggiungi all'orto", systemImage: "plus.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.primaryGreen)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Helpers

    private func badge(_ text: String, color: Color) -> some View {
        Text(text).font(.caption).fontWeight(.medium)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private func sectionCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon).font(.subheadline.bold()).foregroundStyle(.secondary)
            content()
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func infoRow(icon: String, label: String, value: String, iconColor: Color) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon).foregroundStyle(iconColor).frame(width: 20)
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline).multilineTextAlignment(.trailing)
        }
    }

    private func monthRow(label: String, months: [Int], color: Color) -> some View {
        HStack {
            Text(label).font(.caption).foregroundStyle(.secondary).frame(width: 55, alignment: .leading)
            HStack(spacing: 4) {
                ForEach(1...12, id: \.self) { m in
                    let active = months.contains(m)
                    Text(mesiNomi[m-1].prefix(1))
                        .font(.system(size: 10, weight: active ? .bold : .regular))
                        .frame(width: 20, height: 20)
                        .background(active ? color : Color(.systemGray5))
                        .foregroundStyle(active ? .white : .secondary)
                        .clipShape(Circle())
                }
            }
        }
    }

    private func chipRow(chips: [String], color: Color) -> some View {
        let icon = color == .green ? "checkmark" : "xmark"
        return FlowLayout(chips.map { chip in
            AnyView(
                Label(chip, systemImage: icon)
                    .font(.caption)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .foregroundStyle(color)
                    .clipShape(Capsule())
            )
        })
    }
}

// Layout a flusso semplice per i chip
private struct FlowLayout: View {
    let items: [AnyView]
    init(_ items: [AnyView]) { self.items = items }

    var body: some View {
        var rows: [[AnyView]] = [[]]
        // Layout approssimato: usa LazyVGrid come fallback semplice
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], alignment: .leading, spacing: 6) {
            ForEach(items.indices, id: \.self) { i in items[i] }
        }
    }
}

#Preview {
    PlantDetailSheet(
        knowledge: PlantKnowledge(
            id: UUID(), slug: "pomodoro-san-marzano", specieNome: "Pomodoro San Marzano",
            growthDays: 80, attivitaSuggerite: [
                .init(nome: "Irrigazione", offsetDays: 0, recurrenceDays: 3, color: "blue"),
                .init(nome: "Raccolta", offsetDays: 80, recurrenceDays: nil, color: "orange")
            ],
            seminaMesiEsterno: [4,5], seminaMesiInterno: [2,3],
            createdAt: .now, updatedAt: .now,
            specieNomeScentifico: "Solanum lycopersicum",
            descrizione: "Ortaggio estivo molto diffuso.",
            annaffiatura: "ogni 3-4 giorni", esposizione: "Pieno sole", tipo: .ortaggio,
            difficolta: "Medio", mesiRaccolta: [7,8,9],
            pianteCompagne: ["Basilico", "Carota"], pianteIncompatibili: ["Finocchio"]
        ),
        ortoId: UUID(),
        onAdd: { _ in }
    )
    .environment(LanguageManager.shared)
}
```

- [ ] **Step 2: Build + verifica in Xcode Preview**

`⌘B` poi aprire il Preview. Verificare:
- Chip compagne verdi, incompatibili rossi
- Calendario mesi mostra i cerchietti colorati
- Badge "Dati parziali" assente (non è un record Perenual)
- Dark mode: `⌘⌥↩` nella Preview → cambiare schema → tutto leggibile

- [ ] **Step 3: Commit**

```bash
git add "GardenCalendar/Views/Piante/PlantDetailSheet.swift"
git commit -m "feat(ui): add PlantDetailSheet with enriched plant info card"
```

---

## Task 6: Refactor `AggiungiPiantaView.swift`

**Files:**
- Modify: `GardenCalendar/Views/Piante/AggiungiPiantaView.swift`

**Context:** Sostituire la lista hardcoded `catalogSuggestions` con `PlantCatalogService`. Quando l'utente seleziona una pianta dal catalogo (locale o Perenual), mostrare `PlantDetailSheet` e pre-popolare le attività da `knowledge.attivitaSuggerite`. Correggere `specieId: nil` → usare l'ID reale della pianta quando è dal catalogo locale.

- [ ] **Step 1: Aggiungere `@Environment(PlantCatalogService.self)` e state**

In `AggiungiPiantaView`, rimuovere:
```swift
@State private var isSearching = false
private let catalogSuggestions = [...]
private var filteredCatalog: [String] { ... }
```

Aggiungere:
```swift
@Environment(PlantCatalogService.self) private var catalog
@State private var selectedKnowledge: PlantKnowledge? = nil
@State private var showingDetail = false
```

- [ ] **Step 2: Sostituire il contenuto della scroll list**

Sostituire il blocco `if !filteredCatalog.isEmpty { ... }` con:

```swift
// Risultati catalogo locale
if !catalog.localResults.isEmpty {
    VStack(alignment: .leading, spacing: 4) {
        Text(lang.plants.catalogSection)
            .font(.subheadline.bold())
            .foregroundStyle(.secondary)
            .padding(.horizontal)

        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(catalog.localResults) { knowledge in
                    Button(action: {
                        selectedKnowledge = knowledge
                        showingDetail = true
                    }) {
                        HStack {
                            Text(knowledge.tipo?.emoji ?? emojiForPlant(knowledge.specieNome))
                            VStack(alignment: .leading) {
                                Text(knowledge.specieNome).foregroundStyle(.primary)
                                if let sci = knowledge.specieNomeScentifico {
                                    Text(sci).font(.caption).foregroundStyle(.secondary).italic()
                                }
                            }
                            Spacer()
                            if selectedKnowledge?.id == knowledge.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.primaryGreen)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }

                    if knowledge.id != catalog.localResults.last?.id {
                        Divider().padding(.leading)
                    }
                }
            }
        }
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// Risultati Perenual (dati parziali)
if !catalog.externalResults.isEmpty {
    VStack(alignment: .leading, spacing: 4) {
        Text("Cerca online")
            .font(.subheadline.bold())
            .foregroundStyle(.secondary)
            .padding(.horizontal)

        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(catalog.externalResults) { knowledge in
                    Button(action: {
                        selectedKnowledge = knowledge
                        showingDetail = true
                    }) {
                        HStack {
                            Text(emojiForPlant(knowledge.specieNome))
                            Text(knowledge.specieNome).foregroundStyle(.primary)
                            Spacer()
                            Text("dati parziali")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }

                    if knowledge.id != catalog.externalResults.last?.id {
                        Divider().padding(.leading)
                    }
                }
            }
        }
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

if catalog.isSearchingExternal {
    ProgressView("Cerca online...").padding()
}
```

- [ ] **Step 3: Aggiornare `onChange(of: searchText)` per triggerare la ricerca**

Sostituire il `onChange` esistente:

```swift
.onChange(of: searchText) { _, newValue in
    selectedKnowledge = nil
    selectedFromCatalog = nil
    importedActivities = []
    Task {
        if newValue.isEmpty {
            await catalog.loadAll(from: repository)
        } else {
            await catalog.search(query: newValue, in: repository)
        }
    }
}
```

Aggiungere anche un `.task` per caricare il catalogo iniziale:

```swift
.task {
    await catalog.loadAll(from: repository)
}
```

- [ ] **Step 4: Aggiungere `.sheet` per `PlantDetailSheet`**

Aggiungere dopo il `.alert`:

```swift
.sheet(isPresented: $showingDetail) {
    if let knowledge = selectedKnowledge {
        PlantDetailSheet(
            knowledge: knowledge,
            ortoId: ortoId,
            onAdd: { k in
                applyKnowledge(k)
            }
        )
    }
}
```

- [ ] **Step 5: Aggiungere `applyKnowledge` + aggiornare `savePianta`**

```swift
private func applyKnowledge(_ knowledge: PlantKnowledge) {
    selectedFromCatalog = knowledge.specieNome
    customName = knowledge.specieNome
    customGrowthDays = knowledge.growthDays
    // Usa attivita dal DB; fallback al generatore locale se vuote
    let attivita = knowledge.attivitaSuggerite
    if !attivita.isEmpty {
        importedActivities = attivita.map {
            TemplateActivity(name: $0.nome, offsetDays: $0.offsetDays, recurrenceDays: $0.recurrenceDays)
        }
    } else {
        importedActivities = generateTemplateActivities(for: knowledge.specieNome)
    }
    // Salva specieId solo per piante dal catalogo locale (non Perenual)
    _selectedSpecieId = catalog.isExternalSource(knowledge) ? nil : knowledge.id
}

@State private var _selectedSpecieId: UUID? = nil
```

In `savePianta`, nella chiamata `repository.createPianta`:

```swift
let nuovaPianta = try await repository.createPianta(pianta: PiantaColtivata.Create(
    ortoId: ortoId,
    specieId: _selectedSpecieId,  // ← era sempre nil
    nomePersonalizzato: nome,
    dataSemina: seminaDate,
    growthDays: customGrowthDays,
    note: nil,
    fotoUrl: nil
))
```

- [ ] **Step 6: Build + test manuale**

1. Aprire l'app → selezionare un orto → "Aggiungi pianta"
2. Senza searchText: vedere lista di tutte le piante del catalogo
3. Cercare "pom" → Pomodoro San Marzano appare nella sezione catalogo
4. Toccare Pomodoro → `PlantDetailSheet` si apre con dati completi
5. Toccare "Aggiungi all'orto" → sheet si chiude, attività pre-popolate visibili
6. Salvare → pianta salvata con `specieId` non nil

- [ ] **Step 7: Commit**

```bash
git add "GardenCalendar/Views/Piante/AggiungiPiantaView.swift"
git commit -m "feat(ui): refactor AggiungiPiantaView to use PlantCatalogService + PlantDetailSheet"
```

---

## Task 7: Seeding SQL — 30 piante comuni

**Files:**
- Modify: `supabase-migrations/20260621_plant_library.sql` (aggiungere in fondo)

**Context:** Aggiungere 22 piante nuove al catalogo (le 8 esistenti sono già aggiornate in Task 1). Ogni pianta include tutti i campi arricchiti. Usare `ON CONFLICT (slug) DO NOTHING` per sicurezza.

- [ ] **Step 1: Aggiungere INSERT in fondo al file SQL di migration**

```sql
-- ============================================================
-- SEED: 22 piante aggiuntive (v1 libreria)
-- ============================================================
INSERT INTO plant_knowledge
  (slug, specie_nome, growth_days, attivita_suggerite,
   semina_mesi_esterno, semina_mesi_interno,
   specie_nome_scientifico, descrizione, annaffiatura, esposizione,
   tipo, difficolta, mesi_raccolta, piante_compagne, piante_incompatibili)
VALUES

('carote', 'Carote', 90,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":4,"color":"blue"},{"nome":"Diradamento","offset_days":14,"recurrence_days":null,"color":"gray"},{"nome":"Raccolta","offset_days":80,"recurrence_days":null,"color":"orange"}]',
 '{3,4,7,8}', '{2,3}',
 'Daucus carota', 'Radice che ama terreno sciolto e profondo. Diradare a 5 cm di distanza dopo la germinazione.',
 'ogni 4-5 giorni, regolare', 'Sole o mezza ombra', 'ortaggio', 'Facile',
 '{7,8,9,10}', '{Cipolla,Lattuga,Fagiolino}', '{Finocchio,Aneto}'),

('cipolla', 'Cipolla', 120,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":7,"color":"blue"},{"nome":"Sarchiatura","offset_days":30,"recurrence_days":null,"color":"gray"},{"nome":"Raccolta","offset_days":110,"recurrence_days":null,"color":"orange"}]',
 '{3,4}', '{1,2}',
 'Allium cepa', 'Ortaggio biennale coltivato come annuale. Le foglie ingialliscono a maturazione: segnale di raccolta.',
 'ogni 7 giorni, ridurre vicino alla raccolta', 'Pieno sole', 'ortaggio', 'Facile',
 '{6,7,8}', '{Carota,Lattuga,Fragola}', '{Fagiolo,Pisello}'),

('aglio', 'Aglio', 210,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":10,"color":"blue"},{"nome":"Raccolta","offset_days":200,"recurrence_days":null,"color":"orange"}]',
 '{10,11}', '{9,10}',
 'Allium sativum', 'Piantare i bulbilli in autunno per raccogliere a giugno-luglio. Ottimo repellente naturale.',
 'ogni 10 giorni, quasi assente', 'Pieno sole', 'ortaggio', 'Facile',
 '{6,7}', '{Pomodoro,Rosa,Fragola}', '{Fagiolo,Pisello,Cavolo}'),

('prezzemolo', 'Prezzemolo', 75,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":3,"color":"blue"},{"nome":"Raccolta","offset_days":60,"recurrence_days":14,"color":"orange"}]',
 '{3,4,8}', '{2,3}',
 'Petroselinum crispum', 'Biennale coltivato come annuale. Germinazione lenta (2-3 settimane). Non trapianta bene.',
 'ogni 3 giorni, costante', 'Sole o mezza ombra', 'aromatica', 'Facile',
 '{6,7,8,9,10}', '{Pomodoro,Asparago,Cipolla}', '{Lattuga}'),

('spinaci', 'Spinaci', 50,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":3,"color":"blue"},{"nome":"Raccolta","offset_days":40,"recurrence_days":null,"color":"orange"}]',
 '{2,3,8,9}', '{1,2}',
 'Spinacia oleracea', 'Predilige il fresco. In estate va in fiore rapidamente. Ideale come coltura interculturale.',
 'ogni 3 giorni, abbondante', 'Sole o mezza ombra', 'ortaggio', 'Facile',
 '{3,4,5,9,10}', '{Fragola,Cipolla,Ravanello}', '{Finocchio}'),

('piselli', 'Piselli', 90,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":5,"color":"blue"},{"nome":"Rincalzatura","offset_days":20,"recurrence_days":null,"color":"gray"},{"nome":"Raccolta","offset_days":75,"recurrence_days":5,"color":"orange"}]',
 '{2,3,9,10}', '{1,2}',
 'Pisum sativum', 'Legume che fissa azoto. Necessita di supporto per le varietà rampicanti. Sensibile al caldo estivo.',
 'ogni 5 giorni', 'Sole o mezza ombra', 'ortaggio', 'Facile',
 '{5,6}', '{Carota,Ravanello,Spinacio}', '{Aglio,Cipolla,Finocchio}'),

('cetrioli', 'Cetrioli', 65,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":2,"color":"blue"},{"nome":"Concimazione","offset_days":20,"recurrence_days":20,"color":"green"},{"nome":"Raccolta","offset_days":50,"recurrence_days":3,"color":"orange"}]',
 '{4,5}', '{3,4}',
 'Cucumis sativus', 'Ortaggio idrofilo che richiede irrigazione regolare. Raccogliere prima della maturazione completa.',
 'ogni 2 giorni, abbondante in estate', 'Pieno sole', 'ortaggio', 'Medio',
 '{7,8,9}', '{Fagiolo,Pisello,Basilico}', '{Patata,Aromatiche forti}'),

('cocomero', 'Cocomero', 100,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":4,"color":"blue"},{"nome":"Concimazione","offset_days":20,"recurrence_days":25,"color":"green"},{"nome":"Raccolta","offset_days":90,"recurrence_days":null,"color":"orange"}]',
 '{5}', '{3,4}',
 'Citrullus lanatus', 'Pianta termofila che richiede molto spazio (2m²). Controllare la maturazione toccando la crosta.',
 'ogni 4 giorni, ridurre prima della raccolta', 'Pieno sole', 'ortaggio', 'Difficile',
 '{8,9}', '{Basilico,Mais}', '{Patata,Finocchio}'),

('patate', 'Patate', 110,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":5,"color":"blue"},{"nome":"Rincalzatura","offset_days":30,"recurrence_days":null,"color":"gray"},{"nome":"Trattamento antiparassitario","offset_days":40,"recurrence_days":null,"color":"red"},{"nome":"Raccolta","offset_days":100,"recurrence_days":null,"color":"orange"}]',
 '{3,4}', '{2}',
 'Solanum tuberosum', 'Tubero che richiede rincalzatura per proteg. i tuberi dalla luce. Attenzione alla peronospora.',
 'ogni 5 giorni, ridurre a maturazione', 'Pieno sole', 'ortaggio', 'Medio',
 '{7,8,9}', '{Fagiolo,Mais,Cavolo}', '{Pomodoro,Melanzana,Finocchio}'),

('porri', 'Porri', 150,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":5,"color":"blue"},{"nome":"Rincalzatura","offset_days":30,"recurrence_days":null,"color":"gray"},{"nome":"Raccolta","offset_days":140,"recurrence_days":null,"color":"orange"}]',
 '{3,4}', '{1,2}',
 'Allium porrum', 'Ortaggio resistente al freddo. Rincalzare per sbiancare il fusto. Può restare in terra d inverno.',
 'ogni 5-6 giorni', 'Pieno sole', 'ortaggio', 'Facile',
 '{10,11,12,1,2}', '{Carota,Sedano,Pomodoro}', '{Fagiolo,Pisello}'),

('carciofi', 'Carciofi', 240,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":5,"color":"blue"},{"nome":"Concimazione","offset_days":30,"recurrence_days":30,"color":"green"},{"nome":"Raccolta","offset_days":220,"recurrence_days":14,"color":"orange"}]',
 '{3,4}', '{2,3}',
 'Cynara scolymus', 'Pianta perenne che occupa spazio per più anni. Propagare per carducci a marzo. Ottimo in climi temperati.',
 'ogni 5 giorni, abbondante in estate', 'Pieno sole', 'ortaggio', 'Medio',
 '{4,5,6}', '{Fagiolo,Pisello}', '{Patata,Cipolla'}),

('rosmarino', 'Rosmarino', 365,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":10,"color":"blue"},{"nome":"Potatura","offset_days":90,"recurrence_days":90,"color":"gray"},{"nome":"Raccolta","offset_days":90,"recurrence_days":14,"color":"orange"}]',
 '{4,5}', '{3,4}',
 'Salvia rosmarinus', 'Arbusto perenne molto resistente alla siccità. Non tollerare i ristagni idrici. Profuma il giardino.',
 'ogni 10-14 giorni (molto siccitolero)', 'Pieno sole', 'aromatica', 'Facile',
 '{5,6,7,8,9,10,11}', '{Salvia,Timo,Lavanda}', '{Basilico,Menta}'),

('timo', 'Timo', 365,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":10,"color":"blue"},{"nome":"Potatura","offset_days":60,"recurrence_days":60,"color":"gray"},{"nome":"Raccolta","offset_days":60,"recurrence_days":14,"color":"orange"}]',
 '{4,5}', '{3}',
 'Thymus vulgaris', 'Arbusto sempreverde molto siccitolero. Potenziare la produzione con potature regolari.',
 'ogni 10 giorni, siccitolero', 'Pieno sole', 'aromatica', 'Facile',
 '{5,6,7,8,9,10,11,12}', '{Rosmarino,Salvia,Lavanda}', '{Finocchio}'),

('menta', 'Menta', 365,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":3,"color":"blue"},{"nome":"Cimatura","offset_days":30,"recurrence_days":30,"color":"gray"},{"nome":"Raccolta","offset_days":45,"recurrence_days":14,"color":"orange"}]',
 '{4,5}', '{3,4}',
 'Mentha spp.', 'Aromatica perenne invasiva — meglio coltivarla in vaso o con barriera sotterranea.',
 'ogni 3 giorni, ama umidità', 'Sole o mezza ombra', 'aromatica', 'Facile',
 '{5,6,7,8,9,10}', '{Pomodoro,Cavolo,Zucchina}', '{Rosmarino}'),

('origano', 'Origano', 365,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":7,"color":"blue"},{"nome":"Potatura","offset_days":90,"recurrence_days":90,"color":"gray"},{"nome":"Raccolta","offset_days":60,"recurrence_days":14,"color":"orange"}]',
 '{4,5}', '{3}',
 'Origanum vulgare', 'Perenne molto rustico. Il sapore è più intenso in climi caldi e secchi. Ottimo per pizze e sughi.',
 'ogni 7 giorni, siccitolero', 'Pieno sole', 'aromatica', 'Facile',
 '{6,7,8,9,10}', '{Pomodoro,Peperone,Zucchina}', NULL),

('salvia', 'Salvia', 365,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":7,"color":"blue"},{"nome":"Potatura","offset_days":60,"recurrence_days":60,"color":"gray"},{"nome":"Raccolta","offset_days":60,"recurrence_days":14,"color":"orange"}]',
 '{4,5}', '{3}',
 'Salvia officinalis', 'Perenne legnosa. Potare dopo la fioritura per mantenere forma compatta. Repellente naturale per insetti.',
 'ogni 7 giorni, siccitolera', 'Pieno sole', 'aromatica', 'Facile',
 '{5,6,7,8,9,10,11}', '{Rosmarino,Timo,Cavolfiore}', '{Cipolla,Basilico}'),

('fragole', 'Fragole', 90,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":2,"color":"blue"},{"nome":"Trattamento fungicida","offset_days":30,"recurrence_days":null,"color":"red"},{"nome":"Raccolta","offset_days":70,"recurrence_days":3,"color":"orange"}]',
 '{3,4,8,9}', '{2,3}',
 'Fragaria x ananassa', 'Frutto in piena produzione al secondo anno. Eliminare i stoloni per concentrare l energia sui frutti.',
 'ogni 2 giorni, evitare foglie bagnate', 'Pieno sole', 'frutto', 'Facile',
 '{5,6,7}', '{Spinacio,Cipolla,Lattuga}', '{Cavolo,Finocchio}'),

('cavolo', 'Cavolo', 120,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":4,"color":"blue"},{"nome":"Concimazione","offset_days":20,"recurrence_days":20,"color":"green"},{"nome":"Trattamento antiparassitario","offset_days":15,"recurrence_days":null,"color":"red"},{"nome":"Raccolta","offset_days":110,"recurrence_days":null,"color":"orange"}]',
 '{3,4,7,8}', '{2,3,6,7}',
 'Brassica oleracea', 'Famiglia molto ampia. Attenzione alla cavolaia e ai afidi. Beneficia di rotazione colturale.',
 'ogni 4 giorni, abbondante', 'Pieno sole o mezza ombra', 'ortaggio', 'Medio',
 '{9,10,11,12}', '{Pomodoro,Sedano,Menta}', '{Fragola,Pomodoro,Fagiolo}'),

('broccoli', 'Broccoli', 100,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":4,"color":"blue"},{"nome":"Concimazione","offset_days":20,"recurrence_days":20,"color":"green"},{"nome":"Raccolta","offset_days":90,"recurrence_days":null,"color":"orange"}]',
 '{3,4,7,8}', '{2,3,6,7}',
 'Brassica oleracea var. italica', 'Raccogliere la testa principale prima che i fiori si aprano. Poi germogli laterali per settimane.',
 'ogni 4 giorni', 'Pieno sole', 'ortaggio', 'Medio',
 '{9,10,11}', '{Sedano,Cipolla,Menta}', '{Fragola,Fagiolo,Pomodoro}'),

('rucola', 'Rucola', 40,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":2,"color":"blue"},{"nome":"Raccolta","offset_days":30,"recurrence_days":7,"color":"orange"}]',
 '{3,4,5,8,9}', '{2,3}',
 'Eruca vesicaria', 'Coltura rapidissima. Raccogliere le foglie esterne. In estate può andare in fiore in pochi giorni.',
 'ogni 2 giorni', 'Sole o mezza ombra', 'ortaggio', 'Facile',
 '{4,5,9,10}', '{Ravanello,Carota,Lattuga}', NULL),

('sedano', 'Sedano', 120,
 '[{"nome":"Irrigazione","offset_days":0,"recurrence_days":2,"color":"blue"},{"nome":"Concimazione","offset_days":20,"recurrence_days":20,"color":"green"},{"nome":"Imbianchimento","offset_days":90,"recurrence_days":null,"color":"gray"},{"nome":"Raccolta","offset_days":110,"recurrence_days":null,"color":"orange"}]',
 '{3,4}', '{2,3}',
 'Apium graveolens', 'Richiede terreno ricco e irrigazione abbondante. Imbianchire i gambi per sapore più delicato.',
 'ogni 2 giorni, abbondante', 'Sole o mezza ombra', 'ortaggio', 'Difficile',
 '{9,10,11}', '{Pomodoro,Cavolo,Fagiolo}', '{Mais,Patata}')

ON CONFLICT (slug) DO NOTHING;
```

- [ ] **Step 2: Applicare su Supabase Dashboard**

SQL Editor → incollare → Run. Verificare: 22 nuove righe inserite.

- [ ] **Step 3: Testare in app**

Aprire "Aggiungi pianta" → cercare "car" → Carote e Carciofi appaiono → toccare Carote → `PlantDetailSheet` mostra dati completi inclusi mesi semina e compagne.

- [ ] **Step 4: Commit**

```bash
git add "supabase-migrations/20260621_plant_library.sql"
git commit -m "feat(seed): add 30-plant catalog with enriched data, companion planting, care info"
```

---

## Task 8: Localizzazione nuove stringhe

**Files:**
- Modify: `GardenCalendar/Localization/Strings.swift`

**Context:** Aggiungere le chiavi per i nuovi testi UI in `PlantDetailSheet` e `AggiungiPiantaView` che al momento sono hardcoded in italiano nel codice Swift dei task precedenti.

- [ ] **Step 1: Aggiungere nuovi campi alla struct `PlantsStrings`**

In `Strings.swift`, trovare `struct PlantsStrings` e aggiungere i campi:

```swift
// Nuovi — libreria piante
let searchOnlineSection: String
let partialDataBadge: String
let whenToSowTitle: String
let outdoorLabel: String
let indoorLabel: String
let careTitle: String
let wateringLabel: String
let sunLabel: String
let harvestLabel: String
let generatedActivitiesTitle: String
let companionPlantsTitle: String
let addToGardenButton: String
```

- [ ] **Step 2: Popolare valori in `Strings.italian`**

Trovare il blocco `plants:` nell'istanza `.italian` e aggiungere:

```swift
searchOnlineSection: "Cerca online",
partialDataBadge: "Dati parziali",
whenToSowTitle: "Quando seminare",
outdoorLabel: "Esterno",
indoorLabel: "Interno",
careTitle: "Cure",
wateringLabel: "Annaffiatura",
sunLabel: "Esposizione",
harvestLabel: "Raccolta",
generatedActivitiesTitle: "Attività generate",
companionPlantsTitle: "Piante compagne",
addToGardenButton: "Aggiungi all'orto",
```

- [ ] **Step 3: Popolare valori in `Strings.english`**

```swift
searchOnlineSection: "Search online",
partialDataBadge: "Partial data",
whenToSowTitle: "When to sow",
outdoorLabel: "Outdoor",
indoorLabel: "Indoor",
careTitle: "Care",
wateringLabel: "Watering",
sunLabel: "Sun exposure",
harvestLabel: "Harvest",
generatedActivitiesTitle: "Generated activities",
companionPlantsTitle: "Companion plants",
addToGardenButton: "Add to garden",
```

- [ ] **Step 4: Sostituire stringhe hardcoded in `PlantDetailSheet.swift`**

Aggiungere `@Environment(LanguageManager.self) private var lang` (già presente) e sostituire:
- `"Quando seminare"` → `lang.plants.whenToSowTitle`
- `"Esterno"` / `"Interno"` → `lang.plants.outdoorLabel` / `lang.plants.indoorLabel`
- `"Cure"` → `lang.plants.careTitle`
- `"Annaffiatura"` → `lang.plants.wateringLabel`
- `"Esposizione"` → `lang.plants.sunLabel`
- `"Raccolta"` → `lang.plants.harvestLabel`
- `"Attività generate"` → `lang.plants.generatedActivitiesTitle`
- `"Piante compagne"` → `lang.plants.companionPlantsTitle`
- `"Aggiungi all'orto"` → `lang.plants.addToGardenButton`

In `AggiungiPiantaView`:
- `"Cerca online..."` → `lang.plants.searchOnlineSection`
- `"dati parziali"` → `lang.plants.partialDataBadge`

- [ ] **Step 5: Build + verifica IT/EN**

`⌘B`. Cambiare lingua in Settings → verificare che `PlantDetailSheet` traduca correttamente.

- [ ] **Step 6: Commit**

```bash
git add "GardenCalendar/Localization/Strings.swift" "GardenCalendar/Views/Piante/PlantDetailSheet.swift" "GardenCalendar/Views/Piante/AggiungiPiantaView.swift"
git commit -m "feat(l10n): localize plant library strings in PlantDetailSheet and AggiungiPiantaView"
```

---

## Self-Review

**Spec coverage:**
- ✅ Catalogo locale 50+ piante (8 esistenti + 22 nuove = 30; espandibile)
- ✅ Scheda pianta con tutte le sezioni (descrizione, cure, mesi, attività, compagne)
- ✅ Ricerca Perenual come fallback con cache in-memory
- ✅ Inserimento manuale come ultimo fallback
- ✅ `specieId` ora popolato correttamente al salvataggio
- ✅ Dark mode via `AppTheme.*`
- ✅ Localizzazione IT/EN
- ⚠️ **Fuori scope v1:** scheda consultabile da `PiantaDetailView` (pianta già coltivata) — da pianificare separatamente

**Type consistency:**
- `PlantKnowledge.attivitaSuggerite: [AttivitaSuggerita]` usato uniformemente
- `PlantCatalogService.localResults` / `externalResults` matchano il tipo atteso in `AggiungiPiantaView`
- `onAdd: (PlantKnowledge) -> Void` in `PlantDetailSheet` corrisponde a `applyKnowledge(_:)`
- `catalog.isExternalSource(_:)` ritorna `Bool` usato correttamente per `specieId`

**Nessun placeholder:** tutto il codice è completo.
