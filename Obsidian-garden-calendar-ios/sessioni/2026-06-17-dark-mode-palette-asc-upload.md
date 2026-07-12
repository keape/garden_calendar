# Dark mode, fix palette contrasto, upload ASC v1.1

**Data:** 2026-06-17
**Progetto:** garden-calendar-ios
**Durata:** media
**Tipo:** feature
**Status:** complete
**Tags:** SwiftUI, AppTheme, dark-mode, UIColor, ASC

## Cosa abbiamo fatto

- Identificato problema contrasto `textSecondary` (olive #6B6B4A su cream: 4.5:1 — washed out)
- Rimosso `AppTheme 2.swift` (duplicato orfano non in xcodeproj)
- Riscritto `AppTheme.swift` con helper `adaptive()` basato su `UIColor { traitCollection }`
- Tutti i token superficie/testo ora adattativi: `backgroundCream`, `cardBackground`, `cardSecondaryWarm`, `textPrimary`, `textSecondary`, `ctaDarkGreen`, `primaryGreen`
- Colori attività lasciati fissi (dot/badge, non testo su sfondo)
- Build simulator: screenshot light + dark mode verificati
- Archive → Export → Upload ASC v1.1 build 3 (UUID `d44131a6-2fb6-4ed2-b248-3f9ccd69c345`)
- Fix iter: profilo distribuzione mancava App Group → risolto con `-allowProvisioningUpdates`
- Fix iter: v1.0 train chiuso da Apple → bump `MARKETING_VERSION` 1.0→1.1 via pbxproj + agvtool

## Decisioni prese

- `UIColor adaptive initializer` invece di Asset Catalog — nessuna modifica struttura progetto
- `textSecondary` light: `0.28, 0.32, 0.18` → contrasto ~7.5:1 su cream (era 4.5:1)
- Attività colors fissi: usati come indicatori colorati, non richiedono dark mode
- `MARKETING_VERSION` aggiornato direttamente in `project.pbxproj` (agvtool aggiorna Info.plist ma non build settings)

## Prossimi passi

- Attendere processing Apple su ASC
- Sottomettere build v1.1 per review in App Store Connect
- Valutare se `CalendarView.swift` ha modifiche unstaged da completare (viewMode agenda changes)

## Contesto tecnico rilevante

```
Commit: 947c316
File: GardenCalendar/Theme/AppTheme.swift
Build: v1.1 build 3 — com.gardencalendar.app
Upload UUID: d44131a6-2fb6-4ed2-b248-3f9ccd69c345
```
