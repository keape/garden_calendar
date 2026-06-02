# Fix errore schema cache e decodifica date Supabase

**Data:** 2026-06-02
**Progetto:** garden-calendar-ios
**Durata:** lunga
**Tipo:** bug
**Status:** complete
**Tags:** supabase, swift, swiftui, codable, postgresql

## Cosa abbiamo fatto

- Rimosso `dataRaccoltaPrevista` come stored property da `PiantaColtivata` → convertito in computed property (non esiste nel DB)
- Rimosso `dataRaccoltaPrevista` da `CodingKeys`, `PiantaColtivata.Create`, `PiantaColtivata.Update`
- Aggiunto custom `JSONDecoder` in `SupabaseConfig.client` per gestire date PostgreSQL `date` (formato `yyyy-MM-dd`) oltre a ISO8601 timestamptz
- Testato end-to-end nel Simulator: aggiunta Melanzana → lista aggiornata a 4 piante, nessun errore

## Decisioni prese

- `dataRaccoltaPrevista` resta computed (`dataSemina + growthDays`): non serve persistenza, evita colonna DB aggiuntiva
- Custom decoder condiviso in `SupabaseConfig` (non per-model): tutte le query usano lo stesso decoder coerente

## Prossimi passi

Nessun follow-up aperto.

## Contesto tecnico rilevante

File modificati:
- `GardenCalendar/Models/PiantaColtivata.swift` — computed property + CodingKeys ripuliti
- `GardenCalendar/SupabaseConfig.swift` — custom JSONDecoder (ISO8601 + yyyy-MM-dd)
- `GardenCalendar/Views/Piante/AggiungiPiantaView.swift` — rimosso `dataRaccoltaPrevista` dal Create
- `GardenCalendar/Views/Piante/PiantaDetailView.swift` — rimosso dal Preview
