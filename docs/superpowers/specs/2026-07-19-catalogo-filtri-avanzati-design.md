# Filtri avanzati Catalogo Piante

## Contesto
`CatalogoView.swift` filtra oggi per: testo libero (nome/nome scientifico), categoria (`PlantType`), toggle "seminabili ora". `PlantKnowledge` espone altri campi non ancora filtrabili: `difficolta` (stringa normalizzata: facile/media/difficile), `esposizione` (testo libero da AI extraction, es. "Pieno sole (6+ ore)", "Sole o mezza ombra"), `mesiRaccolta` ([Int]?).

## Obiettivo
Aggiungere 3 filtri: difficoltà, esposizione, mese di raccolta.

## Design

### Stato
```swift
@State private var difficoltaFiltro: String? = nil   // "facile" | "media" | "difficile"
@State private var esposizioneFiltro: EsposizioneBucket? = nil
@State private var meseRaccoltaFiltro: Int? = nil     // 1-12
@State private var showFiltriSheet = false

enum EsposizioneBucket: String, CaseIterable {
    case sole, mezzaOmbra, ombra
}
```

### Matching esposizione
`esposizione` è testo libero. Bucket assegnato da funzione pura `esposizioneBucket(for: String) -> EsposizioneBucket?`, case-insensitive, valutata in quest'ordine:
1. contiene "mezza ombra" o "mezz'ombra" → `.mezzaOmbra`
2. altrimenti contiene "ombra" → `.ombra`
3. altrimenti contiene "sole" → `.sole`
4. nessun match → `nil` (pianta esclusa se il filtro esposizione è attivo)

Una pianta con testo "Pieno sole o mezza ombra" finisce in `.mezzaOmbra` (bucket più specifico), non in entrambi.

### Filtro mese raccolta
Chip mesi 1-12 (abbreviazioni localizzate già presenti in `monthAbbrs`/simili). Match: `mesiRaccolta?.contains(mese) == true`. Piante con `mesiRaccolta == nil` escluse quando filtro attivo.

### UI
Bottone icona `slider.horizontal.3` nella toolbar/accanto alla search bar, con badge numerico (conteggio filtri attivi tra difficoltà/esposizione/mese — categoria e seminabiliOra restano come oggi, non contano nel badge). Tap apre `.sheet` con:
- Sezione Difficoltà: 3 chip (facile/media/difficile), selezione singola, tap su selezionata deseleziona
- Sezione Esposizione: 3 chip (Sole/Mezza ombra/Ombra), stessa logica
- Sezione Mese raccolta: 12 chip mesi in grid/scroll, stessa logica
- Bottone "Reset filtri" in fondo, disabilitato se nessun filtro attivo
- Bottone "Applica"/chiusura standard sheet (toolbar "Fine")

`filteredCatalogo` estende la catena di filtri esistente con i 3 nuovi predicati (AND logico con quelli già presenti).

### Localizzazione
Nuove chiavi in `PlantsStrings` (IT + EN): `filtersButtonLabel`, `difficultyFilterSection`, `exposureFilterSection`, `harvestMonthFilterSection`, `difficultyEasy`, `difficultyMedium`, `difficultyHard`, `exposureSun`, `exposurePartialShade`, `exposureShade`, `resetFiltersButton`.

## Fuori scope
- Normalizzazione DB del campo `esposizione` (resta testo libero, si continua a bucketizzare lato client)
- Ordinamento risultati (non richiesto)
- Persistenza filtri tra sessioni
