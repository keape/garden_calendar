# Filtri avanzati Catalogo Piante Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aggiungere a `CatalogoView` filtri per difficoltà, esposizione e mese di raccolta, accessibili da uno sheet dedicato con badge conteggio.

**Architecture:** Nuovo bottone icona in `CatalogoView` apre un `.sheet` con 3 sezioni di chip a selezione singola (difficoltà/esposizione/mese raccolta). Lo stato dei filtri vive in `CatalogoView` come `@State`; una funzione pura `esposizioneBucket(for:)` in `PlantKnowledge.swift` bucketizza il campo testo libero `esposizione`. `filteredCatalogo` applica i nuovi predicati in AND con quelli esistenti.

**Tech Stack:** SwiftUI, nessun framework di test nel progetto (nessun target XCTest esistente) — verifica tramite build (`xcodebuild build`) e test manuale in simulatore, seguendo la convenzione già in uso nel progetto.

## Global Constraints

- Segue spec `docs/superpowers/specs/2026-07-19-catalogo-filtri-avanzati-design.md`.
- Difficoltà valori: `facile`, `media`, `difficile` (case-insensitive match sul campo `difficolta`).
- Esposizione bucket priorità: "mezza ombra"/"mezz'ombra" → `.mezzaOmbra`; altrimenti "ombra" → `.ombra`; altrimenti "sole" → `.sole`; nessun match → `nil` (esclusa se filtro attivo).
- Mese raccolta: match su `mesiRaccolta?.contains(mese) == true`; piante con `mesiRaccolta == nil` escluse se filtro attivo.
- Badge conta solo i 3 nuovi filtri (non categoria, non "seminabili ora").
- Tutte le stringhe UI localizzate IT+EN in `Strings.swift` (`PlantsStrings`), pattern esistente.
- Non modificare `SowingCalculator`, `filteredCatalogo` esistente per categoria/ricerca/seminabiliOra resta invariato salvo aggiunta AND dei nuovi predicati.

---

### Task 1: Modello `EsposizioneBucket` e funzione di bucketizzazione

**Files:**
- Modify: `GardenCalendar/Models/PlantKnowledge.swift:25` (subito dopo la chiusura di `enum PlantType`, prima di `struct PlantKnowledge`)

**Interfaces:**
- Produces: `enum EsposizioneBucket: String, CaseIterable, Sendable { case sole, mezzaOmbra, ombra }` con `var displayName: String` NON incluso qui (le label localizzate vivono in `Strings.swift`, consumate da `CatalogoView`); espone `var localizationKey` no — i task successivi mappano il caso al testo tramite `lang.plants` con uno `switch` locale in `CatalogoView`, quindi qui serve solo l'enum grezzo.
- Produces: `func esposizioneBucket(for esposizione: String?) -> EsposizioneBucket?` — funzione libera a livello di file (non un metodo, per restare testabile/chiamabile senza istanza).

**Note implementativa:** nessun target di test nel progetto (verificato: `find . -iname "*Tests*"` non produce target applicativo, solo dipendenze SPM di terze parti). La correttezza si verifica con le asserzioni manuali del Passo 2 tramite uno script Swift throwaway, poi rimosso — non un test permanente.

- [ ] **Step 1: Aggiungi enum e funzione in `PlantKnowledge.swift`**

Inserisci dopo la riga 25 (dopo la chiusura di `enum PlantType { ... }`, prima di `struct PlantKnowledge`):

```swift
enum EsposizioneBucket: String, CaseIterable, Sendable {
    case sole, mezzaOmbra, ombra
}

/// Bucketizza il campo testo libero `esposizione` (generato da AI extraction, es.
/// "Pieno sole (6+ ore)", "Sole o mezza ombra") in una categoria filtrabile.
/// Priorità: mezza ombra > ombra > sole, perché "mezza ombra" contiene "ombra" come sottostringa.
func esposizioneBucket(for esposizione: String?) -> EsposizioneBucket? {
    guard let testo = esposizione?.lowercased() else { return nil }
    if testo.contains("mezza ombra") || testo.contains("mezz'ombra") {
        return .mezzaOmbra
    }
    if testo.contains("ombra") {
        return .ombra
    }
    if testo.contains("sole") {
        return .sole
    }
    return nil
}
```

- [ ] **Step 2: Verifica manuale della logica (throwaway script, non committato)**

Crea un file temporaneo `/tmp/verify_bucket.swift` (fuori dal repo) con questi casi e i risultati attesi, eseguilo con `swift /tmp/verify_bucket.swift`, controlla a occhio l'output, poi cancella il file:

```swift
func esposizioneBucket(for esposizione: String?) -> String? {
    guard let testo = esposizione?.lowercased() else { return nil }
    if testo.contains("mezza ombra") || testo.contains("mezz'ombra") { return "mezzaOmbra" }
    if testo.contains("ombra") { return "ombra" }
    if testo.contains("sole") { return "sole" }
    return nil
}

let cases: [(String?, String?)] = [
    ("Pieno sole (6+ ore)", "sole"),
    ("Pieno sole o mezza ombra", "mezzaOmbra"),
    ("Sole o mezza ombra", "mezzaOmbra"),
    ("Ombra parziale", "ombra"),
    ("Pieno sole", "sole"),
    (nil, nil),
    ("Terreno drenato", nil),
]
for (input, expected) in cases {
    let got = esposizioneBucket(for: input)
    let ok = got == expected
    print("\(ok ? "OK" : "FAIL") input=\(input ?? "nil") got=\(got ?? "nil") expected=\(expected ?? "nil")")
}
```

Expected output: 7 righe tutte `OK`. Se una fallisce, correggi la funzione in `PlantKnowledge.swift` (non lo script) e ripeti.

Comando: `swift /tmp/verify_bucket.swift`

- [ ] **Step 3: Rimuovi lo script throwaway**

```bash
rm /tmp/verify_bucket.swift
```

- [ ] **Step 4: Commit**

```bash
git add "GardenCalendar/Models/PlantKnowledge.swift"
git commit -m "feat(piante): aggiungi EsposizioneBucket per bucketizzare campo esposizione libero"
```

---

### Task 2: Stringhe localizzate per i filtri

**Files:**
- Modify: `GardenCalendar/Localization/Strings.swift:226` (dichiarazioni in `PlantsStrings`, subito dopo `let chooseGardenTitle: String`)
- Modify: `GardenCalendar/Localization/Strings.swift:529` (init IT, dopo `chooseGardenTitle: "Scegli un orto"`)
- Modify: `GardenCalendar/Localization/Strings.swift:814` (init EN, dopo `chooseGardenTitle: "Choose a garden"`)

**Interfaces:**
- Produces: nuovi campi su `Strings.shared.plants` (o equivalente istanza corrente via `lang.plants`, pattern già usato in `CatalogoView`/`PlantDetailSheet`): `filtersButtonLabel`, `filtersSheetTitle`, `difficultyFilterSection`, `exposureFilterSection`, `harvestMonthFilterSection`, `difficultyEasy`, `difficultyMedium`, `difficultyHard`, `exposureSun`, `exposurePartialShade`, `exposureShade`, `resetFiltersButtonLabel`, `doneButtonLabel` — tutti `String`.

- [ ] **Step 1: Aggiungi le dichiarazioni al struct `PlantsStrings`**

In `GardenCalendar/Localization/Strings.swift`, sostituisci la riga 226 (`let chooseGardenTitle: String`) con:

```swift
        let chooseGardenTitle: String
        let filtersButtonLabel: String
        let filtersSheetTitle: String
        let difficultyFilterSection: String
        let exposureFilterSection: String
        let harvestMonthFilterSection: String
        let difficultyEasy: String
        let difficultyMedium: String
        let difficultyHard: String
        let exposureSun: String
        let exposurePartialShade: String
        let exposureShade: String
        let resetFiltersButtonLabel: String
        let doneButtonLabel: String
```

- [ ] **Step 2: Aggiungi i valori italiani**

Sostituisci la riga `chooseGardenTitle: "Scegli un orto"` (nel blocco IT, circa riga 529) con:

```swift
            chooseGardenTitle: "Scegli un orto",
            filtersButtonLabel: "Filtri",
            filtersSheetTitle: "Filtra catalogo",
            difficultyFilterSection: "Difficoltà",
            exposureFilterSection: "Esposizione",
            harvestMonthFilterSection: "Mese di raccolta",
            difficultyEasy: "Facile",
            difficultyMedium: "Media",
            difficultyHard: "Difficile",
            exposureSun: "Sole",
            exposurePartialShade: "Mezza ombra",
            exposureShade: "Ombra",
            resetFiltersButtonLabel: "Reimposta filtri",
            doneButtonLabel: "Fine"
```

- [ ] **Step 3: Aggiungi i valori inglesi**

Sostituisci la riga `chooseGardenTitle: "Choose a garden"` (nel blocco EN, circa riga 814) con:

```swift
            chooseGardenTitle: "Choose a garden",
            filtersButtonLabel: "Filters",
            filtersSheetTitle: "Filter catalog",
            difficultyFilterSection: "Difficulty",
            exposureFilterSection: "Exposure",
            harvestMonthFilterSection: "Harvest month",
            difficultyEasy: "Easy",
            difficultyMedium: "Medium",
            difficultyHard: "Hard",
            exposureSun: "Full sun",
            exposurePartialShade: "Partial shade",
            exposureShade: "Shade",
            resetFiltersButtonLabel: "Reset filters",
            doneButtonLabel: "Done"
```

- [ ] **Step 4: Build per verificare che tutte le istanze di `PlantsStrings` compilino**

```bash
xcodebuild -project GardenCalendar.xcodeproj -scheme GardenCalendar -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -40
```

Expected: `** BUILD SUCCEEDED **`. Se fallisce con "missing argument" su `PlantsStrings(...)`, significa che c'è un'altra istanza di `PlantsStrings` oltre a IT/EN (cerca con `grep -n "PlantsStrings(" GardenCalendar/Localization/Strings.swift`) da aggiornare allo stesso modo.

- [ ] **Step 5: Commit**

```bash
git add "GardenCalendar/Localization/Strings.swift"
git commit -m "feat(i18n): aggiungi stringhe IT/EN per filtri avanzati catalogo"
```

---

### Task 3: UI filtri in `CatalogoView`

**Files:**
- Modify: `GardenCalendar/Views/Piante/CatalogoView.swift`

**Interfaces:**
- Consumes: `esposizioneBucket(for:) -> EsposizioneBucket?` e `EsposizioneBucket` da Task 1 (funzione libera, stesso modulo `GardenCalendar`, nessun import aggiuntivo necessario).
- Consumes: `lang.plants.filtersButtonLabel`, `.filtersSheetTitle`, `.difficultyFilterSection`, `.exposureFilterSection`, `.harvestMonthFilterSection`, `.difficultyEasy`, `.difficultyMedium`, `.difficultyHard`, `.exposureSun`, `.exposurePartialShade`, `.exposureShade`, `.resetFiltersButtonLabel`, `.doneButtonLabel` da Task 2.
- Consumes: `PlantKnowledge.difficolta: String?`, `PlantKnowledge.esposizione: String?`, `PlantKnowledge.mesiRaccolta: [Int]?` (esistenti).
- Produces: nessuna nuova interfaccia pubblica — tutto privato a `CatalogoView`.

- [ ] **Step 1: Aggiungi stato filtri**

In `CatalogoView.swift`, subito dopo `@State private var soloSeminabiliOra = false` (riga 15), aggiungi:

```swift
    @State private var difficoltaFiltro: String? = nil
    @State private var esposizioneFiltro: EsposizioneBucket? = nil
    @State private var meseRaccoltaFiltro: Int? = nil
    @State private var showFiltriSheet = false
```

- [ ] **Step 2: Estendi `filteredCatalogo` con i nuovi predicati**

Sostituisci il corpo di `filteredCatalogo` (righe 42-61) con:

```swift
    private var filteredCatalogo: [PlantKnowledge] {
        var risultato = catalogo
        if let categoriaFiltro {
            risultato = risultato.filter { $0.tipo == categoriaFiltro }
        }
        if soloSeminabiliOra {
            let interno = orti.first?.interno ?? false
            let mese = normals != nil ? Calendar.current.component(.month, from: Date()) : meseEffettivo
            risultato = risultato.filter { pk in
                let window = SowingCalculator.compute(for: pk, normals: normals)
                let mesi = interno ? window.seminaInterno : window.seminaEsterno
                return mesi.contains(mese)
            }
        }
        if let difficoltaFiltro {
            risultato = risultato.filter { $0.difficolta?.lowercased() == difficoltaFiltro }
        }
        if let esposizioneFiltro {
            risultato = risultato.filter { esposizioneBucket(for: $0.esposizione) == esposizioneFiltro }
        }
        if let meseRaccoltaFiltro {
            risultato = risultato.filter { $0.mesiRaccolta?.contains(meseRaccoltaFiltro) == true }
        }
        guard !searchText.isEmpty else { return risultato }
        return risultato.filter {
            $0.specieNome.localizedCaseInsensitiveContains(searchText)
                || ($0.specieNomeScentifico?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    private var activeFilterCount: Int {
        [difficoltaFiltro != nil, esposizioneFiltro != nil, meseRaccoltaFiltro != nil]
            .filter { $0 }.count
    }
```

- [ ] **Step 3: Aggiungi il bottone "Filtri" con badge accanto alla search bar**

Sostituisci il blocco:

```swift
                searchBar
                    .padding(.horizontal)
                    .padding(.top, 8)
```

con:

```swift
                HStack(spacing: 8) {
                    searchBar
                    filtersButton
                }
                .padding(.horizontal)
                .padding(.top, 8)
```

- [ ] **Step 4: Implementa `filtersButton` e lo sheet dei filtri**

Aggiungi queste nuove computed properties nella sezione `// MARK: - Search & Filters`, subito dopo `categoryFilterBar` (dopo la chiusura della property, prima di `categoryChip`):

```swift
    private var filtersButton: some View {
        Button {
            showFiltriSheet = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(12)
                    .background(AppTheme.cardSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                if activeFilterCount > 0 {
                    Text("\(activeFilterCount)")
                        .font(.dmSans(10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(AppTheme.primaryGreen)
                        .clipShape(Circle())
                        .offset(x: 6, y: -6)
                }
            }
        }
    }

    private var monthAbbrs: [String] {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: lang.dayDetail.dateLocale)
        return fmt.veryShortStandaloneMonthSymbols
    }

    private var filtriSheet: some View {
        NavigationStack {
            List {
                Section(lang.plants.difficultyFilterSection) {
                    ForEach(["facile", "media", "difficile"], id: \.self) { livello in
                        filtroRow(
                            label: livelloLabel(livello),
                            isSelected: difficoltaFiltro == livello
                        ) {
                            difficoltaFiltro = difficoltaFiltro == livello ? nil : livello
                        }
                    }
                }
                Section(lang.plants.exposureFilterSection) {
                    ForEach(EsposizioneBucket.allCases, id: \.self) { bucket in
                        filtroRow(
                            label: esposizioneLabel(bucket),
                            isSelected: esposizioneFiltro == bucket
                        ) {
                            esposizioneFiltro = esposizioneFiltro == bucket ? nil : bucket
                        }
                    }
                }
                Section(lang.plants.harvestMonthFilterSection) {
                    ForEach(1...12, id: \.self) { mese in
                        filtroRow(
                            label: monthAbbrs[mese - 1],
                            isSelected: meseRaccoltaFiltro == mese
                        ) {
                            meseRaccoltaFiltro = meseRaccoltaFiltro == mese ? nil : mese
                        }
                    }
                }
                Section {
                    Button(role: .destructive) {
                        difficoltaFiltro = nil
                        esposizioneFiltro = nil
                        meseRaccoltaFiltro = nil
                    } label: {
                        Text(lang.plants.resetFiltersButtonLabel)
                    }
                    .disabled(activeFilterCount == 0)
                }
            }
            .navigationTitle(lang.plants.filtersSheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.plants.doneButtonLabel) {
                        showFiltriSheet = false
                    }
                }
            }
        }
    }

    private func filtroRow(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(AppTheme.primaryGreen)
                }
            }
        }
    }

    private func livelloLabel(_ livello: String) -> String {
        switch livello {
        case "facile": return lang.plants.difficultyEasy
        case "media": return lang.plants.difficultyMedium
        default: return lang.plants.difficultyHard
        }
    }

    private func esposizioneLabel(_ bucket: EsposizioneBucket) -> String {
        switch bucket {
        case .sole: return lang.plants.exposureSun
        case .mezzaOmbra: return lang.plants.exposurePartialShade
        case .ombra: return lang.plants.exposureShade
        }
    }
```

- [ ] **Step 5: Collega lo sheet alla view**

Nel blocco `.sheet` esistenti dentro `body` (dopo `.confirmationDialog(...)`, prima di `.sheet(item: $addPiantaContext)`), aggiungi:

```swift
            .sheet(isPresented: $showFiltriSheet) {
                filtriSheet
                    .environment(lang)
            }
```

- [ ] **Step 6: Build**

```bash
xcodebuild -project GardenCalendar.xcodeproj -scheme GardenCalendar -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -60
```

Expected: `** BUILD SUCCEEDED **`. Errori tipici da controllare: nome esatto di `AppTheme.cardSecondary`/`AppTheme.primaryGreen` (già usati altrove nel file, non dovrebbero cambiare), `lang.dayDetail.dateLocale` esistente (usato in `PlantDetailSheet.swift:23`).

- [ ] **Step 7: Test manuale in simulatore**

Avvia l'app in simulatore (Xcode → Run, o `xcodebuild ... test` non applicabile, nessun target UI test). Vai alla tab Catalogo:
1. Tap sull'icona filtri → si apre lo sheet con 3 sezioni.
2. Seleziona "Facile" → chiudi sheet → verifica che il badge mostri "1" e la lista si sia ridotta a piante con `difficolta == "facile"`.
3. Aggiungi anche un filtro esposizione e uno mese raccolta → badge deve mostrare "3", lista filtrata per AND di tutti.
4. Tap "Reimposta filtri" → tutti i filtri si azzerano, badge sparisce.
5. Verifica che categoria e "Seminabili ora" continuino a funzionare come prima e si combinino correttamente con i nuovi filtri.

- [ ] **Step 8: Commit**

```bash
git add "GardenCalendar/Views/Piante/CatalogoView.swift"
git commit -m "feat(piante): aggiungi filtri difficoltà/esposizione/mese raccolta al catalogo"
```

---

## Self-Review Notes

- **Spec coverage:** difficoltà ✓ (Task 3 Step 2/4), esposizione ✓ (Task 1 + Task 3), mese raccolta ✓ (Task 3), sheet con badge ✓ (Task 3 Step 3-4), reset filtri ✓ (Task 3 Step 4), localizzazione IT/EN ✓ (Task 2). Fuori scope confermato: nessuna normalizzazione DB, nessun ordinamento, nessuna persistenza tra sessioni — nessun task li tocca.
- **Placeholder scan:** nessun TBD/TODO; ogni step ha codice completo.
- **Type consistency:** `EsposizioneBucket` (Task 1) usato identico in Task 3 (`EsposizioneBucket.allCases`, `esposizioneBucket(for:)`); campi `Strings.plants.*` (Task 2) referenziati con nomi identici in Task 3; `PlantKnowledge.difficolta/.esposizione/.mesiRaccolta` invariati rispetto al modello esistente.
