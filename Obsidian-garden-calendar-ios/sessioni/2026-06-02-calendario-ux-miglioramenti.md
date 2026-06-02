# Miglioramenti UX vista Calendario

**Data:** 2026-06-02
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** feature
**Status:** complete
**Tags:** SwiftUI, iOS, CalendarView, NavigationStack, Agenda

## Cosa abbiamo fatto

- Rimosso spazio grigio eccessivo sopra/sotto il calendario: background `AppTheme.cardSecondary` ora applicato solo al blocco calendario, non al `Spacer()`
- Aggiunto `NavigationStack` con titolo "Calendario" in `CalendarGridView`
- Aggiunto pulsante **"Oggi"** in toolbar (`.navigationBarTrailing`), disabilitato se già nel mese corrente
- Sostituita legenda con soli pallini colorati → griglia 2 colonne con pallino + etichetta (Semina/Trapianto, Raccolta, Irrigazione, Trattamento, Potatura/Sarchiatura, Promemoria)
- Aggiunto picker segmentato **Calendario / Agenda** in cima alla vista
- Implementata vista **Agenda**: attività future (≥ oggi) ordinate per data, raggruppate con header "Oggi"/"Domani"/data, riusa `DayActivityRow`; stato vuoto se nessuna attività

## Decisioni prese

- Agenda riusa `DayActivityRow` esistente invece di creare un nuovo componente → meno codice duplicato
- Background grigio solo sul blocco griglia/legenda, `Spacer()` fuori → sfondo sistema bianco sotto, layout pulito
- Picker segmentato invece di tab separati → meno navigazione, contesto unico

## Prossimi passi

- Implementare `loadMonth()` in `CalendarGridView` per fetchare attività reali da Supabase (attualmente TODO)
- L'agenda sarà automaticamente popolata una volta che il fetch è attivo

## Contesto tecnico rilevante

File modificato: `GardenCalendar/Views/Calendario/CalendarView.swift`
Build e test eseguiti su simulator iOS 18.5 (device "Test", UUID `347C86A2-71AD-48EA-BFC6-38BB624202E8`) via `xcodebuild`.
