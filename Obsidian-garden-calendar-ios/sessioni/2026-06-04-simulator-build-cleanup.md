# Build su Simulator e pulizia device CoreSimulator

**Data:** 2026-06-04
**Progetto:** garden-calendar-ios
**Durata:** media
**Tipo:** config
**Status:** complete
**Tags:** xcode, coresimulator, ios-simulator, build, rain-adjuster

## Cosa abbiamo fatto

- Eliminato 32 device simulator in eccesso (rimasti: iPhone 16 iOS 18.5 + iPhone 17 Pro iOS 26.5)
- Build `GardenCalendar` con `xcodebuild -destination "id=F4D2A264..."` → BUILD SUCCEEDED
- Boot simulatore iPhone 16 iOS 18.5 (`F4D2A264-CB52-4F14-8E4D-AB4316CCC746`)
- Install + launch app su simulatore — app visibile e funzionante

## Decisioni prese

- Tenere solo 2 device: iPhone 16 iOS 18.5 (target build corrente) + iPhone 17 Pro iOS 26.5 (test iOS moderno)
- CoreSimulator resta su interno per vincolo APFS sealed runtimes (cross-container clonefile fallisce); memoria salvata in `feedback_coresimulator_external.md`

## Prossimi passi

- Testare funzionalità rain-rescheduling nell'app sul simulatore
- Verificare che `applyRainRescheduling()` si comporti correttamente con dati reali Supabase

## Contesto tecnico rilevante

- Bundle ID: `com.gardencalendar.app`
- Build output: `SYMROOT=/tmp/GardenCalendarBuild`
- Device UDID iPhone 16 iOS 18.5: `F4D2A264-CB52-4F14-8E4D-AB4316CCC746`
- Device UDID iPhone 17 Pro iOS 26.5: `AA142611-3F77-4D30-9818-B87032702213`
