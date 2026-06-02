# Aggiunta eliminazione orto dalla vista modifica

**Data:** 2026-06-02
**Progetto:** garden-calendar-ios
**Durata:** breve
**Tipo:** feature
**Status:** complete
**Tags:** swiftui, ios, supabase, orto

## Cosa abbiamo fatto

- Aggiunto bottone "Elimina orto" (rosso, destructive) nel sheet di modifica `OrtoDetailView`
- Aggiunto alert di conferma con messaggio e bottoni "Annulla" / "Elimina"
- Aggiunta funzione `deleteOrto()` che chiama `repository.deleteOrto(id:)` e poi `dismiss()`
- Aggiunto `@Environment(\.dismiss)` e `@State private var showDeleteOrtoConfirm` in `OrtoDetailView`
- Cambiato `.presentationDetents([.medium])` in `[.medium, .large]` perché il bottone era fuori dallo schermo
- Aggiunto `.onAppear { Task { await loadOrti() } }` in `OrtoListView` per ricaricare la lista dopo il pop da detail
- Testato nel simulatore iOS 18.5: funziona, alert visibile e corretto

## Decisioni prese

- `.presentationDetents([.medium, .large])` invece di solo `.medium` per permettere scroll e visibilità di tutti i controlli del form
- Delete eseguita in `OrtoDetailView` (non solo in `OrtoListView`) per coerenza UX — l'utente può eliminare direttamente dalla vista dettaglio
- `OrtoListView` usa `.onAppear` per reload perché `.task` non si ri-esegue al pop di navigazione

## Prossimi passi

- Nessun follow-up aperto.

## Contesto tecnico rilevante

File modificati:
- `GardenCalendar/Views/Orto/OrtoDetailView.swift`
- `GardenCalendar/Views/Orto/OrtoListView.swift`

`deleteOrto()` in `OrtoDetailView`:
```swift
private func deleteOrto() {
    Task {
        do {
            try await repository.deleteOrto(id: orto.id)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```
