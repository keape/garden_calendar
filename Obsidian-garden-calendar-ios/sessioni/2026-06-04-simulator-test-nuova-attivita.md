# Test Simulator: NuovaAttivitaSheet e ModificaPiantaSheet

**Data:** 2026-06-04
**Progetto:** garden-calendar-ios
**Durata:** media
**Tipo:** debug
**Status:** complete
**Tags:** SwiftUI, Simulator, cliclick, PiantaDetailView, NuovaAttivitaSheet

## Cosa abbiamo fatto

- Ripreso sessione precedente: verificare che il pulsante "+" in `activitiesSection` apra `NuovaAttivitaSheet`
- Navigato nel Simulator iPhone 16 fino a `PiantaDetailView` per la pianta "Peperone" (orto "Campo")
- Identificato problema: coordinate cliclick non atterravano sul pulsante "+"
- Diagnosticato offset errato: Simulator window era a (0,30) non (0,0), ma calibrazione y_start=119 era già corretta per quella posizione
- Risolto usando `System Events → click at {407, 563}` via AppleScript invece di cliclick: garantisce focus corretto al processo Simulator
- Verificato apertura `NuovaAttivitaSheet`: titolo "Nuova attività", TextField, Picker "Ricorrente", Stepper "Ogni 7 giorni"

## Decisioni prese

- `osascript` con `System Events → click at` è più affidabile di `cliclick` per interagire con il Simulator: gestisce il focus del processo automaticamente.
- Calibrazione offset Mac screen → iOS pt rimane: x_start=44, y_start=119 (invariata anche con Simulator a y=30 perché era già così in sessione precedente).

## Prossimi passi

- Nessun follow-up aperto: entrambe le funzionalità (`Modifica` e `+`) verificate e funzionanti.

## Contesto tecnico rilevante

- Bundle ID: `com.gardencalendar.app`
- Simulator UDID: `F4D2A264-CB52-4F14-8E4D-AB4316CCC746`
- Coordinate "+" button: Mac screen (407, 563) → iOS pt (~363, ~444)
- Comando verifica screenshot: `xcrun simctl io <UDID> screenshot /tmp/file.png`
- Click affidabile: `osascript -e 'tell application "System Events" to tell process "Simulator" to click at {407, 563}'`
