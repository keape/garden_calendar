# Localizzazione IT/EN — Design Spec
**Data:** 2026-06-10  
**Feature:** Selezione lingua in-app (Italiano / English)  
**Approccio scelto:** `@Observable LanguageManager` + struct tipizzate  

---

## 1. Obiettivo

Aggiungere alla schermata Impostazioni un selettore lingua (Italiano / English). Il cambio deve propagarsi istantaneamente a tutte le view senza riavvio dell'app. La lingua scelta persiste in `UserDefaults`.

## 2. Architettura Core

### 2.1 `Strings.swift` — unico file con tutte le traduzioni

Posizione: `GardenCalendar/Localization/Strings.swift`

Struttura:
```swift
struct Strings {
    struct Common  { let cancel, confirm, ok, error, save, delete, edit, add, close: String }
    struct Auth    { let loginTitle, loginSubtitle, loginButton, signUpLink, forgotPassword,
                         signUpTitle, signUpButton, loginLink,
                         emailPlaceholder, passwordPlaceholder, confirmPasswordPlaceholder,
                         resetTitle, resetMessage, resetSent, resetButton,
                         appleSignIn, errorUnknown: String }
    struct Settings { let title, profileSection, logoutButton, logoutConfirmTitle, logoutConfirmMsg,
                          preferredGardenSection, defaultGarden,
                          weatherSection, weatherPlaceholder, rainThreshold, rainFooter,
                          notificationsSection, dailyReminder, reminderHour, notifFooter,
                          notifDeniedTitle, notifDeniedMsg,
                          appearanceSection, theme, themeLight, themeDark, themeAuto,
                          languageSection, languageLabel,
                          infoSection, version, builtWith,
                          deleteAccountButton, deleteAccountFooter,
                          deleteConfirmTitle, deleteConfirmMsg, deleteConfirmPlaceholder,
                          deleteConfirmKeyword, deleteConfirmButton,
                          deletedTitle, deletedMsg: String }
    struct Calendar { let title, today, noActivities, activitiesCount, markDone, markUndone,
                          rainBadge, frostWarning, addActivity, deleteActivity,
                          confirmDeleteTitle, confirmDeleteMsg: String }
    struct Plants   { let title, addPlant, editPlant, deletePlant, confirmDeleteTitle, confirmDeleteMsg,
                          noPlants, plantName, species, intervalDays, lastDone, nextDue,
                          overdue, doneToday, activities, addActivity, editInterval,
                          saveButton, cancelButton, notesPlaceholder: String }
    struct Garden   { let title, addGarden, editGarden, deleteGarden, confirmDeleteTitle, confirmDeleteMsg,
                          noGardens, gardenName, noPlants, addPlant: String }
    struct Journal  { let title, newNote, saveNote, deleteNote, notePlaceholder,
                          confirmDeleteTitle, confirmDeleteMsg, emptyState: String }
    struct Notifications { let dailyTitle, dailyBody, andMore: String }

    let common:        Common
    let auth:          Auth
    let settings:      Settings
    let calendar:      Calendar
    let plants:        Plants
    let garden:        Garden
    let journal:       Journal
    let notifications: Notifications
}
```

Le due istanze statiche `Strings.italian` e `Strings.english` sono definite nello stesso file. Aggiungere una nuova proprietà a un namespace senza aggiornarle entrambe causa errore di compilazione — garanzia automatica di completezza.

### 2.2 `AppLanguage` enum

```swift
enum AppLanguage: String, CaseIterable {
    case it = "it"
    case en = "en"

    var strings: Strings {
        switch self {
        case .it: return .italian
        case .en: return .english
        }
    }

    var displayName: String {
        switch self {
        case .it: return "Italiano"
        case .en: return "English"
        }
    }
}
```

### 2.3 `LanguageManager`

```swift
@Observable
final class LanguageManager {
    static let shared = LanguageManager()

    private(set) var strings: Strings
    var language: AppLanguage {
        didSet {
            strings = language.strings
            UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
        }
    }

    // Forward per ergonomia nelle view
    var common:        Strings.Common        { strings.common }
    var auth:          Strings.Auth          { strings.auth }
    var settings:      Strings.Settings      { strings.settings }
    var calendar:      Strings.Calendar      { strings.calendar }
    var plants:        Strings.Plants        { strings.plants }
    var garden:        Strings.Garden        { strings.garden }
    var journal:       Strings.Journal       { strings.journal }
    var notifications: Strings.Notifications { strings.notifications }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "it"
        let lang = AppLanguage(rawValue: saved) ?? .it
        self.language = lang
        self.strings = lang.strings
    }
}
```

## 3. Integrazione nell'app

### 3.1 Root injection

In `GardenCalendarApp.swift`, aggiungere `.environment(LanguageManager.shared)` alla WindowGroup root view. Una sola modifica propaga il manager a tutta la gerarchia.

### 3.2 Pattern nelle view

```swift
struct SomeView: View {
    @Environment(LanguageManager.self) var lang

    var body: some View {
        Text(lang.settings.profilo)
        Button(lang.common.cancel) { ... }
    }
}
```

### 3.3 NotificationManager (no SwiftUI environment)

`NotificationManager` è un servizio non-SwiftUI. Accede direttamente al singleton:
```swift
content.title = LanguageManager.shared.notifications.dailyTitle
content.body  = "..."  // costruito con lang.notifications.dailyBody
```

## 4. UI Impostazioni — Sezione Lingua

Nuova sezione **sopra "Aspetto"** in `SettingsView`:

```
LINGUA / LANGUAGE
  🌍  Lingua / Language     [Italiano ▾]
```

`Picker` con `.menu` style, binding `$languageManager.language`. Nessun footer necessario — il cambio è istantaneo e visibile.

Il `ThemeMode.rawValue` in `SettingsView` usa già stringhe italiane (`"chiaro"`, `"scuro"`, `"automatico"`); queste rimangono come valori interni (non UI) — non cambiano.

## 5. File da creare/modificare

| File | Tipo | Modifica |
|---|---|---|
| `GardenCalendar/Localization/Strings.swift` | **Nuovo** | Tutte le stringhe IT+EN + LanguageManager |
| `GardenCalendar/GardenCalendarApp.swift` | Modifica | +1 riga `.environment(LanguageManager.shared)` |
| `GardenCalendar/Views/Settings/SettingsView.swift` | Modifica | Sezione lingua + uso `lang.*` |
| `GardenCalendar/Views/Auth/LoginView.swift` | Modifica | Uso `lang.auth.*` |
| `GardenCalendar/Views/Auth/SignUpView.swift` | Modifica | Uso `lang.auth.*` |
| `GardenCalendar/Views/Calendario/CalendarView.swift` | Modifica | Uso `lang.calendar.*` |
| `GardenCalendar/Views/Calendario/DayDetailSheet.swift` | Modifica | Uso `lang.calendar.*` |
| `GardenCalendar/Views/Piante/PiantaListView.swift` | Modifica | Uso `lang.plants.*` |
| `GardenCalendar/Views/Piante/PiantaDetailView.swift` | Modifica | Uso `lang.plants.*` |
| `GardenCalendar/Views/Piante/AggiungiPiantaView.swift` | Modifica | Uso `lang.plants.*` |
| `GardenCalendar/Views/Piante/ModificaPiantaSheet.swift` | Modifica | Uso `lang.plants.*` |
| `GardenCalendar/Views/Piante/ModificaIntervalloSheet.swift` | Modifica | Uso `lang.plants.*` |
| `GardenCalendar/Views/Piante/NuovaAttivitaSheet.swift` | Modifica | Uso `lang.plants.*` |
| `GardenCalendar/Views/Orto/OrtoListView.swift` | Modifica | Uso `lang.garden.*` |
| `GardenCalendar/Views/Orto/OrtoDetailView.swift` | Modifica | Uso `lang.garden.*` |
| `GardenCalendar/Views/Journal/QuickJournalView.swift` | Modifica | Uso `lang.journal.*` |
| `GardenCalendar/Services/NotificationManager.swift` | Modifica | Uso `LanguageManager.shared.notifications.*` |

**Totale:** 1 file nuovo + 16 modifiche.

## 6. Vincoli e decisioni esplicite

- **Chiavi interne non tradotte:** `ThemeMode.rawValue` (`"chiaro"`/`"scuro"`), nomi colore nei modelli, chiavi Supabase — rimangono in italiano come valori dati, non UI.
- **Persistenza:** `UserDefaults` locale. Nessuna sincronizzazione iCloud — scelta utente per dispositivo.
- **Default:** Se nessun valore salvato, default a `.it` (comportamento attuale preservato).
- **Stringa "ELIMINA" nel delete confirm:** In inglese diventa `"DELETE"` — la keyword è localizzata insieme a tutto il flusso.
- **Preview Xcode:** Passare `LanguageManager.shared` all'environment nei preview esistenti.
