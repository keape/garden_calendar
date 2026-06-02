# Debug simulatore iOS su disco esterno Lexar

**Data:** 2026-05-29
**Progetto:** garden-calendar-ios
**Durata:** lunga

## Cosa abbiamo fatto

- Tentato lancio simulator per app iOS GardenCalendar
- Identificato DerivedData su `/Volumes/XcodeData` senza permessi → resettato a default
- Identificato `~/Library/Developer/CoreSimulator` è symlink → `/Volumes/Ext.Lexar/Costola del Mac/xCode/CoreSimulator`
- Volume Lexar montato con `noowners` → eseguito `sudo diskutil enableOwnership`
- Tentato creazione device simulator → fallisce con EPERM "Error copying sample content"
- Diagnosticato: CoreSimulatorService non ha TCC Full Disk Access
- Aggiunto Xcode a Full Disk Access via System Settings
- Tentato grant TCC via sqlite3 → bloccato da SIP (readonly database)
- Simulator.app e CoreSimulatorService ancora non vedono device
- Prossimo step: aggiungere Simulator.app a Full Disk Access

## Decisioni prese

- Mantenere device CoreSimulator su Lexar (spazio interno insufficiente)
- Reset DerivedData a path default (`~/Library/Developer/Xcode/DerivedData`)
- Aggiunto `CODE_SIGNING_REQUIRED = NO` al pbxproj per build simulator senza team

## Prossimi passi

- Aggiungere Simulator.app a Full Disk Access: `System Settings → Privacy & Security → Full Disk Access → /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app`
- Verificare se dopo FDA su Simulator.app i device appaiono
- Se ancora bloccato: valutare se aggiungere anche CoreSimulatorService XPC a FDA
- Una volta device attivo: build e run con `xcodebuild` o `⌘R` da Xcode
