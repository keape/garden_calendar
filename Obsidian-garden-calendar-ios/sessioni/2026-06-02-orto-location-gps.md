# Creazione Orto con GPS e Geocoding

**Data:** 2026-06-02
**Progetto:** garden-calendar-ios
**Durata:** media
**Tipo:** feature
**Status:** complete
**Tags:** SwiftUI, CoreLocation, Supabase, CLGeocoder, iOS

## Cosa abbiamo fatto

- Fix `OrtoListView`: `saveNewOrto` e `loadOrti` avevano `catch {}` silenzioso → aggiunto `errorMessage` + `.alert`
- Aggiunto `latitudine: Double?` e `longitudine: Double?` a modello `Orto` e `Orto.Create`
- Migration SQL eseguita su Supabase via CLI (`supabase db query`)
- Creato `LocationHelper.swift` (CLLocationManager one-shot, gestione autorizzazione)
- Form "Nuovo orto": campo città con geocoding on submit (`CLGeocoder.geocodeAddressString`), bottone GPS con reverse geocode automatico del nome città
- Aggiunto `LocationHelper.swift` al `project.pbxproj` (PBXBuildFile, PBXFileReference, gruppo Services, PBXSourcesBuildPhase)
- Fix preview `OrtoDetailView` con nuovi parametri `latitudine`/`longitudine`
- Build e avvio su simulatore verificati: funziona

## Decisioni prese

- Usato `CLGeocoder` per geocoding testo → coordinate e reverse geocode GPS → nome città (no API key esterna)
- Colonne DB: `latitudine`/`longitudine` (italiano, coerente con `luogo`)
- Migration via `supabase db query --linked` invece del dashboard manuale
- Autenticazione MCP Supabase non funzionante (client_id non registrato) → fallback su CLI

## Prossimi passi

- Task: "Verificare che funzioni la programmazione delle prossime attività" (calendario)
- Task: "Verificare funzione controllo piogge" (usa `latitudine`/`longitudine` appena aggiunti)

## Contesto tecnico rilevante

File modificati:
- `GardenCalendar/Models/Orto.swift`
- `GardenCalendar/Services/SupabaseRepository.swift`
- `GardenCalendar/Services/LocationHelper.swift` (nuovo)
- `GardenCalendar/Views/Orto/OrtoListView.swift`
- `GardenCalendar/Views/Orto/OrtoDetailView.swift`
- `GardenCalendar.xcodeproj/project.pbxproj`
