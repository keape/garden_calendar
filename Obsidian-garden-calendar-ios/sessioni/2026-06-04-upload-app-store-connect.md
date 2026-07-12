# Upload build su App Store Connect via CLI

**Data:** 2026-06-04
**Progetto:** garden-calendar-ios
**Durata:** media
**Tipo:** config
**Status:** complete
**Tags:** xcodebuild, altool, app-store-connect, ios, codesigning

## Cosa abbiamo fatto

- Configurato pipeline CLI completa per upload App Store Connect
- Creato `ExportOptions.plist` con metodo `app-store-connect`, signing automatico, team `4A5H2U7Q42`
- Eseguito `xcodebuild archive` per scheme `GardenCalendar` (Release, iOS generic)
- Risolto errore "No profiles" aggiungendo API key Admin con `-allowProvisioningUpdates`
- Eseguito `xcodebuild -exportArchive` con API key Admin (`65Y6RC34BJ`, issuer `b25721be-1629-4dd6-91ea-46ff3e311bec`)
- Copiato `.p8` in `~/.appstoreconnect/private_keys/` (richiesto da `altool`)
- Upload riuscito via `xcrun altool --upload-app` — Delivery UUID `aa800cf5-9c27-41dc-8646-12c78131b828`

## Decisioni prese

- API key Admin (non Developer/App Manager) necessaria per cloud signing e provisioning automatico
- `.p8` deve stare in `~/.appstoreconnect/private_keys/` — `altool` non accetta path assoluti
- Metodo export: `app-store-connect` (deprecato `app-store`)

## Prossimi passi

- Attendere 5-10 min processing Apple, poi submit in review da App Store Connect

## Contesto tecnico rilevante

```bash
# Archive
xcodebuild archive \
  -project "GardenCalendar.xcodeproj" \
  -scheme GardenCalendar \
  -configuration Release \
  -archivePath build/GardenCalendar.xcarchive \
  -destination "generic/platform=iOS"

# Export
xcodebuild -exportArchive \
  -archivePath build/GardenCalendar.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist \
  -allowProvisioningUpdates \
  -authenticationKeyPath ~/.appstoreconnect/private_keys/AuthKey_65Y6RC34BJ.p8 \
  -authenticationKeyID 65Y6RC34BJ \
  -authenticationKeyIssuerID b25721be-1629-4dd6-91ea-46ff3e311bec

# Upload
xcrun altool --upload-app \
  -f build/export/GardenCalendar.ipa \
  -t ios \
  --apiKey 65Y6RC34BJ \
  --apiIssuer b25721be-1629-4dd6-91ea-46ff3e311bec
```
