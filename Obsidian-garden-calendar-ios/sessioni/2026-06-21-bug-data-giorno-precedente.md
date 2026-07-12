# Fix bug: attività salvata nel giorno precedente

**Data:** 2026-06-21
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** bug
**Status:** complete
**Tags:** SwiftUI, Supabase, timezone, JSONEncoder, date

## Cosa abbiamo fatto

- Identificato bug: aggiungendo attività manuale nel calendario, veniva salvata il giorno precedente
- Diagnosticato causa root: `encoder.dateEncodingStrategy = .iso8601` in `SupabaseConfig.swift` serializzava le date in UTC
- Con timezone italiano (UTC+2), mezzanotte locale `2026-06-21 00:00:00` diventava `2026-06-20T22:00:00Z` → Supabase salvava `2026-06-20`
- Fix applicato: sostituito `.iso8601` con encoder custom `yyyy-MM-dd` usando `Calendar.current.timeZone`

## Decisioni prese

- Encoder custom `DateFormatter` con `yyyy-MM-dd` e timezone locale: corrisponde al tipo colonna PostgreSQL `date` e non rompe il decoder esistente (già gestiva `yyyy-MM-dd` con UTC in lettura).
- Nessuna modifica al decoder: già corretto.

## Prossimi passi

- Verificare che `rescheduleAttivita` funzioni correttamente con il nuovo encoder (stesso path code).
- Testare su dispositivo fisico con timezone UTC+2.

## Contesto tecnico rilevante

**File modificato:** `GardenCalendar/SupabaseConfig.swift` riga 34-35

Prima:
```swift
let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601
```

Dopo:
```swift
let encoder = JSONEncoder()
let encDF = DateFormatter()
encDF.dateFormat = "yyyy-MM-dd"
encDF.locale = Locale(identifier: "en_US_POSIX")
encDF.timeZone = Calendar.current.timeZone
encoder.dateEncodingStrategy = .formatted(encDF)
```

**Flusso bug:** `QuickJournalView.saveEntry()` → `Calendar.current.startOfDay(for: eventDate)` → `repository.createAttivita()` → encoder ISO8601 UTC → Supabase `date` column.
