# Upload Build 2 su App Store Connect — debug provisioning + IPA manuale

**Data:** 2026-06-11
**Progetto:** garden-calendar-ios
**Durata:** lunga
**Tipo:** debug
**Status:** complete
**Tags:** xcode, appstoreconnect, spaceship, codesign, provisioning

## Cosa abbiamo fatto

- Incrementato build number a 2 via `agvtool`
- Registrato App Group `group.com.gardencalendar.app` su Developer Portal via spaceship
- Associato App Group a entrambi i bundle ID (main + widget)
- Rigenerati provisioning profiles App Store con App Group incluso (IDs: 87U48C44MA, K3NSA6HXSQ)
- Eseguito `xcodebuild archive` senza override CLI per profili
- Costruito IPA manuale (fix Bug 3 Xcode 26.5: widget fuori da PlugIns)
- Upload riuscito con `xcrun altool` via API key — Delivery UUID: `de37145b-8b41-4ca7-bf55-909dfc317bfb`

## Problemi incontrati e soluzioni

1. **spaceship 2.54.1 troppo vecchio**: `olympus.itunes.apple.com` deprecato e non risolvibile → installato fastlane 2.236.1
2. **2FA interattivo non gestibile in background**: spaceship richiede stdin per codice 2FA → piped codice via `echo "XXXXXX" | ruby script.rb`; sessione poi riutilizzata automaticamente
3. **API spaceship cambiata**: `app.groups` non esiste in v2.236 → usato `app.associated_groups` + `app.associate_groups([])`
4. **ASC API non registra App Group identifier**: PATCH bundleIdCapabilities con `APP_GROUPS_IDENTIFIER` dà 409 → unico modo è Developer Portal via spaceship (session-based auth)
5. **Profili con App Groups vuoti**: profili creati via ASC API avevano `com.apple.security.application-groups: []` perché il gruppo non era registrato sul portal → risolto dopo punto 3+4
6. **Override CLI `PROVISIONING_PROFILE_SPECIFIER` applicato a tutti i target**: xcodebuild applica override CLI globalmente, anche al widget → rimosso override, usato solo pbxproj per-target
7. **venv Python /tmp/asc_venv sparito**: sessione precedente, `/tmp` pulito → ricreato con `python3 -m venv /tmp/asc_venv2 && pip install PyJWT cryptography requests`
8. **Bug 3 Xcode 26.5**: widget `GardenCalendarWidgetExtension.appex` in `Products/Applications/` invece di `app/PlugIns/` → IPA costruita manualmente, widget spostato in `Payload/GardenCalendar.app/PlugIns/`

## Decisioni prese

- IPA manuale invece di `xcodebuild -exportArchive`: bypassa Bug 2/3/4 Xcode 26.5 (procedura documentata in Budget365 CLAUDE_xcode.md)
- Altool con API key (`--apiKey`/`--apiIssuer`) invece di app-specific password: evita necessità di generare password dedicata

## Prossimi passi

- Attendere processing Apple in ASC (~15-30 min), poi aggiungere build alla release in TestFlight o direttamente alla submission

## Contesto tecnico rilevante

```bash
# Fix App Group su Developer Portal
echo "CODICE_2FA" | FASTLANE_PASSWORD="..." ruby /tmp/associate_appgroup.rb

# Archive
xcodebuild archive -project GardenCalendar.xcodeproj -scheme GardenCalendar \
  -configuration Release -destination "generic/platform=iOS" \
  -archivePath /tmp/GardenCalendar.xcarchive \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="Apple Distribution" DEVELOPMENT_TEAM=4A5H2U7Q42

# IPA manuale
cp -r GardenCalendar.app Payload/
cp -r GardenCalendarWidgetExtension.appex Payload/GardenCalendar.app/PlugIns/
codesign --force --sign "Apple Distribution: ..." --entitlements widget.plist PlugIns/...appex
codesign --force --sign "Apple Distribution: ..." --entitlements main.plist GardenCalendar.app

# Upload
xcrun altool --upload-app -f /tmp/GardenCalendar_build2.ipa -t ios \
  --apiKey 65Y6RC34BJ --apiIssuer b25721be-1629-4dd6-91ea-46ff3e311bec
```
