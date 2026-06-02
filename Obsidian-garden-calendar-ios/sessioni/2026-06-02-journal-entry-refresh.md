# Fix: Journal Entry non visibile dopo salvataggio

**Data:** 2026-06-02
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** bug
**Status:** complete
**Tags:** SwiftUI, Supabase, iOS, CalendarView, DayDetailSheet

## Cosa abbiamo fatto

- Identificato bug: `loadMonth()` in `CalendarGridView` era uno stub TODO — non chiamava mai Supabase, `activities` sempre vuoto
- Identificato secondo bug: `DayDetailSheet` riceveva `activities` come `let` immutabile — nessun reload dopo chiusura di `QuickJournalView`
- Fix 1: implementato `loadMonth()` con chiamata reale a `repository.fetchAttivita(date: currentMonth)`
- Fix 2: aggiunto `onDismiss` alla sheet di `DayDetailSheet` in `CalendarGridView` per ricaricare il mese
- Fix 3: cambiato `let activities` in `@State private var activities` con init custom in `DayDetailSheet`
- Fix 4: aggiunto `.task { await loadActivities() }` e `onDismiss` sulla sheet di `QuickJournalView` per reload immediato post-salvataggio
- Aggiunto metodo `loadActivities()` in `DayDetailSheet` che filtra per giorno specifico

## Decisioni prese

- `DayDetailSheet` carica dati propri via `.task` invece di dipendere dal parent — più robusto e self-sufficient
- Passaggio delle `activities` dal parent usato come valore iniziale (UX: mostra subito qualcosa, poi refresh async)

## Prossimi passi

- Nessun follow-up aperto.

## Contesto tecnico rilevante

File modificati:
- `GardenCalendar/Views/Calendario/CalendarView.swift` — stub `loadMonth()` → fetch reale + `onDismiss`
- `GardenCalendar/Views/Calendario/DayDetailSheet.swift` — `let activities` → `@State`, init custom, `loadActivities()`, `.task`, `onDismiss`
