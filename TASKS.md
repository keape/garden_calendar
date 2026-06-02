# TASKS — Garden Calendar iOS

## Backlog

- [ ] **Controllo performance Xcode post-migrazione SSD**
  Verificare performance Xcode dopo trasferimento su nuovo modello di archiviazione (nuovo SSD). Analizzare tempi di build, indicizzazione, DerivedData, eventuali regressioni.

- [ ] **Autenticazione via Google**
  Aggiungere Sign in with Google al flow di autenticazione. Includere setup Google Cloud Console, GoogleSignIn SDK, gestione token e integrazione con sistema auth esistente.

- [x] **Verificare che non ci siano errori in fase di creazione nuovo orto**
  Fix `OrtoListView`: `saveNewOrto` e `loadOrti` avevano `catch {}` silenzioso → aggiunto alert errori. Aggiunto `LocationHelper.swift` (CLLocationManager one-shot), campo città con geocoding (`CLGeocoder`), bottone GPS con reverse geocode. `Orto` model + `Orto.Create` aggiornati con `latitudine`/`longitudine`. Migration SQL eseguita su Supabase via CLI.

- [x] **Verificare che non ci siano errori in fase di aggiunta nuova pianta**
  Fix `AggiungiPiantaView`: rimosso `store.addEvent` (inesistente), aggiunto `ortoId: UUID?`, `savePianta` convertita in async Task con `repository.createPianta` + `scheduleActivities`. `OrtoDetailView` ora passa `orto.id`.

- [ ] **Verificare che funzioni la programmazione delle prossime attività**
  Verificare che nella pagina di calendar, a partire dalla data di semina o trapianto per ciascuna pianta, vengano programmate tutte le attività successive.

- [ ] **Verificare che funzioni la funzione di controllo delle piogge passate**
  Verificare che venga verificato se ha piovuto nella zona geografica definita nella fase di creazione dell'orto così da riprogrammare le successive irrigazioni.

## In Progress

## Done

- [x] **Creazione knowledge graph con Graphify**
  Generato grafo del codebase con graphify. Disponibile in `graphify-out/` con god nodes, community structure e relazioni cross-file.
