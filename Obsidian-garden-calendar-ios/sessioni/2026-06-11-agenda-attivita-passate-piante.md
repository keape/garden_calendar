# Agenda: attività passate e nome pianta

**Data:** 2026-06-11
**Progetto:** garden-calendar-ios
**Durata:** media
**Tipo:** bug
**Status:** in-progress
**Tags:** SwiftUI, iOS, CalendarView, Supabase, agenda

## Cosa abbiamo fatto

- Rimosso filtro `>= today` in `agendaContent` (CalendarView.swift:473) — ora Agenda mostra tutte le attività senza tagliare le passate
- Identificato causa radice: `fetchAttivita(date: currentMonth)` carica solo il mese corrente — attività di mesi precedenti non vengono mai caricate in Agenda
- Aggiunta funzione `loadAllActivities()` che chiama `fetchAttivita()` senza filtro data
- Aggiunto `onChange(of: viewMode)` per triggare `loadAllActivities()` al cambio tab verso Agenda, `loadMonth()` al ritorno a Calendario
- Fix `.task` iniziale: `viewMode == .agenda ? loadAllActivities() : loadMonth()` per gestire avvio diretto su tab Agenda
- `piantaNome` in `DayActivityRow` già presente dal fix sessione precedente (2026-06-11-agenda-nome-pianta)
- Testato su simulatore iPhone 16: Agenda si apre, attività caricate, ma **nomi pianta non visibili** e nessuna attività passata

## Decisioni prese

- Due load function distinte (`loadMonth` per calendario, `loadAllActivities` per agenda) invece di un'unica con flag — più leggibile, comportamento separato.
- `loadAllActivities()` non cachea (a differenza di `loadMonth`) — agenda mostra sempre dati freschi.

## Prossimi passi

- **Bug aperto:** nomi pianta non mostrati in Agenda (`piantaNome` nil) — sospetto: `piante` array vuoto al momento del render, o mismatch UUID tra `attivita.pianta_id` e `piante_coltivate.id` in DB. Da verificare con query Supabase diretta.
- **Da verificare:** esistenza attività passate in DB (attività generate con `>= today`, quindi il DB potrebbe non averne di precedenti).
- Build non ancora installata su dispositivo fisico — testare lì con dati reali.

## Contesto tecnico rilevante

File modificato: `GardenCalendar/Views/Calendario/CalendarView.swift`

Funzione aggiunta:
```swift
private func loadAllActivities() async {
    isLoading = true
    if orti.isEmpty { await loadFiltersData() }
    do {
        activities = try await repository.fetchAttivita()
        loadError = nil
        isOffline = false
    } catch {
        loadError = lang.calendar.loadErrorMsg
    }
    isLoading = false
}
```

Modifier aggiunto:
```swift
.onChange(of: viewMode) { _, mode in Task { mode == .agenda ? await loadAllActivities() : await loadMonth() } }
```
