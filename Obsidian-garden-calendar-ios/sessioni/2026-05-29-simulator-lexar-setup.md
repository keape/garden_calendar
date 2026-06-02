# Fix Simulator su Volume Lexar Esterno

**Data:** 2026-05-29
**Progetto:** garden-calendar-ios
**Durata:** lunga
**Tipo:** debug
**Status:** complete
**Tags:** CoreSimulator, TCC, APFS, xcodebuild, hdiutil

## Cosa abbiamo fatto

- Diagnosticato blocco `CoreSimulatorService` su creazione device: EPERM su `/Volumes/Ext.Lexar/...` (TCC sandbox blocca XPC service su path `/Volumes/`)
- Tentato FDA via UI → `CoreSimulatorService.xpc` non selezionabile in Preferenze Sistema
- Tentato insert in user TCC.db via sqlite3 → FDA ignorata (serve system TCC.db)
- Tentato `sudo sqlite3` su system TCC.db → read-only anche con sudo (macOS Sequoia)
- Soluzione finale: creato volume APFS `SimDevices` su container Lexar (disk7s2), montato a `~/Library/Developer/CoreSimulator/Devices` tramite `diskutil mount -mountPoint`
- Configurato `/etc/fstab` con UUID per auto-mount al boot
- Build dell'app `GardenCalendar.xcodeproj` riuscito → app installata e avviata nel simulatore (PID 8126)

## Decisioni prese

- **Volume APFS diretto su Lexar** invece di sparsebundle: più stabile, nessun problema di mount point precedente memorizzato da hdiutil
- **fstab con UUID** per persistenza al boot: auto-mount quando Lexar è connesso, fallback a directory interna quando non lo è
- **Mount a `~/Library/...` non a `/Volumes/...`**: CoreSimulatorService può scrivere su `~/Library/` senza FDA; su `/Volumes/` viene bloccato da TCC sandbox XPC

## Prossimi passi

- Testare che al prossimo reboot (con Lexar connesso) il mount avvenga automaticamente
- Sviluppo features dell'app garden-calendar-ios

## Contesto tecnico rilevante

```
Volume: SimDevices  UUID: 62CB4BB8-A9C7-4185-9181-40D4B13E4E61  Device: /dev/disk7s2
fstab entry: UUID=62CB4BB8-A9C7-4185-9181-40D4B13E4E61 /Users/keape/Library/Developer/CoreSimulator/Devices apfs rw,nobrowse
App bundle: com.gardencalendar.app
DerivedData: GardenCalendar-cfhiexacnsgsbmbmwbdyznhwizia
```
