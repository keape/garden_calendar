# 7 feature GardenCalendar: giardino interno, foto piante, suggerimenti semina, cleanup

**Data:** 2026-06-20
**Progetto:** garden-calendar-ios
**Durata:** lunga
**Tipo:** feature
**Status:** complete
**Tags:** swiftui, supabase, storage, migrations, xcodeproj

## Cosa abbiamo fatto

- **F1** Icona app: rimosso bordo/alpha → full-bleed (no cornice bianca iOS).
- **F2** Rinominato "Orto"→"Giardino" solo IT (Strings.swift), EN invariato.
- **F3** Flag `interno` su `orti`: toggle in creazione/modifica giardino, campi GPS nascosti se interno, gate su `applyRainRescheduling()` (`if orto.interno { continue }`).
- **F4** Emoji automatica pianta: `PlantEmoji.swift` (`emojiForPlant` keyword→emoji, fallback 🌱) + `PlantIconView`.
- **F5** Foto pianta via Supabase Storage: bucket `plant-photos` + 4 policy RLS, `uploadPlantPhoto`, PhotosPicker in AggiungiPianta/PiantaDetail.
- **F6** Fix completamento attività in agenda (callback `onToggle` + mutazione locale optimistic) + modifica data via swipe→DatePicker→`rescheduleAttivita`.
- **F7** Suggerimenti semina mensili: colonne `semina_mesi_esterno/_interno` su `plant_knowledge` (20 specie popolate), `SuggerimentiSeminaView` location-aware (emisfero da latitudine, lat<0 → +6 mesi; interno → array interno) in cima a CalendarGridView.
- Registrati 2 nuovi file Swift nel `project.pbxproj` (progetto non-synchronized).
- Applicate 3 migration al DB remoto (risolto drift history rinominando 2 file ai version-id remoti + rimossi dupe iCloud migrations).
- Cleanup: rimossi 66 file conflitto iCloud `… 2.*` (44 identici + 22 snapshot pre-edit), originali tracked preservati.
- Build SUCCEEDED, app installata e lanciata su simulatore iPhone 17 Pro.

## Decisioni prese

- F5 storage path `{userId}/{piantaId}.jpg` con `upsert: true` (cache AsyncImage accettata come minore).
- F6: mutazione locale optimistic invece di refetch (evita scoping month-windowed di `fetchAttivita`).
- F7: location-aware via latitudine orto rappresentativo (filtrato o primo), non per-pianta.
- Drift migration risolto rinominando file locali ai version-id remoti (NON repair+repush: `raccolti` non idempotente → re-run fallirebbe).
- Cancellati anche i 22 dupe DIFFER: sono snapshot pre-edit, l'originale tracked è la versione corrente.

## Prossimi passi

- Test runtime delle 7 feature sul simulatore (giardino interno, upload foto, suggerimenti semina, completamento agenda).
- Commit delle modifiche (non ancora fatto: rename migration + nuovi file + cleanup in working tree).
- Eventuale bump build/versione per TestFlight.

## Contesto tecnico rilevante

- Nuovi file: `Views/Components/PlantEmoji.swift`, `Views/Components/SuggerimentiSeminaView.swift`.
- Migration: `20260620000001_orto_interno.sql`, `…0002_plant_photos_bucket.sql`, `…0003_plant_knowledge_semina.sql`.
- Rinominati: `20260602000001_activity_overrides`→`20260602214513`, `20260609000001_raccolti`→`20260609213442`.
- Build: `xcodebuild -scheme GardenCalendar -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /tmp/gc_dd CODE_SIGNING_ALLOWED=NO`.
- DB ref Supabase: `kusprtmfxrsnjycyzlgs`.
- API LanguageManager: `lang.language == .it` (enum AppLanguage .it/.en).
- Nota: tool MemPalace disconnessi a fine sessione → diary/KG non aggiornati.
