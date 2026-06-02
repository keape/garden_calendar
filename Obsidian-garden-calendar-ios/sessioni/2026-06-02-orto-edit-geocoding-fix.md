# Fix geocoding città + modifica orto

**Data:** 2026-06-02
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** bug|feature
**Status:** complete
**Tags:** SwiftUI, CoreLocation, Supabase, iOS

## Cosa abbiamo fatto

- Fix bug geocoding: quando l'utente scriveva la città manualmente senza premere Return e toccava Salva, `resolvedLatitude/Longitude` restavano `nil` — solo il testo veniva salvato. Fix: geocodifica avviene nel Task prima del salvataggio se le coordinate sono assenti.
- Fix `Orto.Update` struct: mancavano `latitudine` e `longitudine` — l'update non poteva mai salvare le coordinate.
- Feature: aggiunto bottone "Modifica" in toolbar di `OrtoDetailView`. Sheet pre-popolato con nome, luogo e coordinate esistenti. Stesso flusso GPS + geocoding della creazione. Dopo salvataggio, `orto` locale aggiornato con risposta server.
- Build e test su simulator "Test" (iOS 18.5) con SYMROOT=/tmp per aggirare path iCloud con spazi.

## Decisioni prese

- `OrtoDetailView` ora usa `@State private var orto: Orto` con `init(orto:)` invece di `let orto: Orto`, per aggiornare l'header localmente dopo l'edit senza ricaricare.
- Geocoding in `saveNewOrto`/`saveEdit` usa la stringa `luogo` catturata prima del dismiss del sheet — non dipende da `newLuogo`/`editLuogo` che vengono resettati.

## Prossimi passi

- Nessun follow-up aperto.

## Contesto tecnico rilevante

File modificati:
- `GardenCalendar/Models/Orto.swift` — aggiunto `latitudine`/`longitudine` a `Orto.Update`
- `GardenCalendar/Views/Orto/OrtoListView.swift` — fix `saveNewOrto` geocoding
- `GardenCalendar/Views/Orto/OrtoDetailView.swift` — aggiunta feature modifica orto

Build: `xcodebuild ... SYMROOT=/tmp/GardenCalendarBuild` (workaround path iCloud)
