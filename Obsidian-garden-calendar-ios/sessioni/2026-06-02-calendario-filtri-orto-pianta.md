# Filtri calendario per orto, tipologia e pianta

**Data:** 2026-06-02
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** feature
**Status:** complete
**Tags:** SwiftUI, filtri, CalendarView, Supabase, iOS

## Cosa abbiamo fatto

- Aggiunta barra filtri orizzontale scrollabile in `CalendarGridView` sotto il picker Calendario/Agenda
- Implementati 3 filtri a menu: Orto, Tipologia (derivata da `color`), Pianta
- Aggiunta computed property `filteredActivities` applicata a griglia calendario, celle giorno e vista agenda
- Aggiunta computed property `visiblePiante`: se orto selezionato, menu pianta mostra solo piante di quell'orto
- Aggiunto `loadFiltersData()` che carica orti e piante una volta al lancio via `AuthManager.user?.id`
- Chip visivamente distinte: verde quando filtro attivo, grigio con bordo quando inattivo

## Decisioni prese

- Filtro tipologia usa il campo `color` di `Attivita` come proxy (già allineato alla legenda esistente)
- Cambio orto azzera automaticamente il filtro pianta se la pianta selezionata non appartiene al nuovo orto
- Approccio client-side: carica tutte le attività del mese + piante/orti in memoria, filtra localmente
- `visiblePiante` scoped per orto: quando si seleziona un orto, il menu pianta mostra solo le sue piante

## Prossimi passi

- Nessun follow-up aperto.

## Contesto tecnico rilevante

- File modificato: `GardenCalendar/Views/Calendario/CalendarView.swift`
- Aggiunto `@Environment(AuthManager.self)` alla view
- Relazione dati: `Attivita.piantaId → PiantaColtivata.ortoId → Orto.id` (nessun `ortoId` diretto su `Attivita`)
