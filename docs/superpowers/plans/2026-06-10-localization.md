# Localizzazione IT/EN — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aggiungere selezione lingua IT/EN in-app con switch istantaneo, senza riavvio.

**Architecture:** Un `LanguageManager` `@Observable` espone `strings: Strings`, una struct con tutti i testi annidati per namespace. Cambiare `language` swappa la struct e tutte le view ridisegnano. Persistenza in `UserDefaults`.

**Tech Stack:** SwiftUI, `@Observable`, `UserDefaults`, Xcode 16+

**Spec:** `docs/superpowers/specs/2026-06-10-localization-design.md`

---

## Nota architetturale

- `ViewMode` in `CalendarView.swift` ha rawValues italiani usati come label UI. Nel Task 5 vengono cambiati in chiavi inglesi (`"calendar"`, `"agenda"`) e si usa `lang.calendar` per la label.
- `AggiungiPiantaView` e `QuickJournalView` usano `alertMessage.contains("successo"/"salvato")` per distinguere successo/errore. Nei Task 8 e 10 si aggiunge un `@State var alertIsSuccess = false` per rendere questo corretto in entrambe le lingue.
- `DayDetailView.dateHeaderString` usa `Locale(identifier: "it_IT")` hardcoded — Task 6 lo rende dinamico via `lang.dayDetail.dateLocale`.
- `tipologie` in `CalendarView` è un `let` array con stringhe italiane — Task 5 lo trasforma in `var` computed property.

---

## Task 1: Creare `GardenCalendar/Localization/Strings.swift`

**Files:**
- Create: `GardenCalendar/Localization/Strings.swift`

- [ ] **Step 1: Creare il file con `AppLanguage`, tutte le struct `Strings`, entrambe le lingue, e `LanguageManager`**

Crea `GardenCalendar/Localization/Strings.swift` con il contenuto seguente (file completo):

```swift
import Foundation

// MARK: - AppLanguage

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

// MARK: - Strings

struct Strings {
    struct Common {
        let cancel, save, confirm, delete, edit, add, error, ok, next, retry: String
    }

    struct Auth {
        let appSubtitle: String
        let loginCardTitle: String
        let loginButton: String
        let signUpLink: String
        let forgotPassword: String
        let orSeparator: String
        let appleSignIn: String
        let appleSignInComingSoon: String
        let resetTitle: String
        let resetMessage: String
        let resetEmailPlaceholder: String
        let resetSentTitle: String
        let resetSentMessage: String
        let errorTitle: String
        let errorUnknown: String
        let signUpTitle: String
        let signUpNavTitle: String
        let signUpButton: String
        let loginLink: String
        let emailInvalidError: String
        let passwordMinError: String
        let passwordMatchError: String
        let registrationSuccessTitle: String
        let registrationSuccessMessage: String
    }

    struct SettingsStrings {
        let navTitle: String
        let profileSection: String
        let logoutButton: String
        let logoutConfirmTitle: String
        let logoutConfirmMsg: String
        let preferredGardenSection: String
        let defaultGardenPicker: String
        let weatherSection: String
        let weatherPlaceholder: String
        let rainThresholdLabel: String   // use String(format:, value)
        let rainFooter: String
        let notificationsSection: String
        let dailyReminderToggle: String
        let reminderHourPicker: String
        let notifFooter: String
        let notifDeniedTitle: String
        let notifDeniedMsg: String
        let appearanceSection: String
        let themePicker: String
        let themeLight: String
        let themeDark: String
        let themeAuto: String
        let languageSection: String
        let languagePickerLabel: String
        let infoSection: String
        let versionLabel: String
        let builtWithLabel: String
        let deleteAccountButton: String
        let deleteAccountFooter: String
        let deleteConfirmTitle: String
        let deleteConfirmMsg: String
        let deleteConfirmPlaceholder: String
        let deleteConfirmKeyword: String
        let deleteConfirmButton: String
        let deletedTitle: String
        let deletedMsg: String
    }

    struct CalendarStrings {
        let navTitle: String
        let todayButton: String
        let viewCalendar: String
        let viewAgenda: String
        let weekDays: [String]
        let filterAllGardens: String
        let filterAllTypes: String
        let filterAllPlants: String
        let filterGardenDefault: String
        let filterTypeDefault: String
        let filterPlantDefault: String
        let offlineBanner: String
        let rainToastSingular: String
        let rainToastPlural: String      // use String(format:, count)
        let noActivitiesAgenda: String
        let legendSeedTransplant: String
        let legendHarvest: String
        let legendWatering: String
        let legendTreatment: String
        let legendPruning: String
        let legendReminder: String
        let todayLabel: String
    }

    struct DayDetailStrings {
        let activitiesTitle: String
        let noActivitiesDay: String
        let addActivity: String
        let rainMmFormat: String         // String(format:, mm)
        let frostFormat: String          // String(format:, temp)
        let swipeForward: String
        let swipeBack: String
        let rescheduleTitle: String
        let rescheduleSection: String
        let newDateLabel: String
        let rescheduleConfirm: String
        let dateLocale: String           // "it_IT" / "en_US"
    }

    struct PlantsStrings {
        let navTitle: String
        let searchPlaceholder: String
        let emptyTitle: String
        let emptyDesc: String
        let addPlantButton: String
        let totalDaysFormat: String      // String(format:, days)
        let activitiesCountFormat: String // String(format:, count)
        let editButton: String
        let scheduledSection: String
        let pastSection: String
        let noActivitiesPlant: String
        let activitiesSectionTitle: String
        let harvestSectionTitle: String
        let noHarvests: String
        let completedLabel: String
        let recurringLabel: String
        let catalogSection: String
        let catalogSearchPlaceholder: String
        let customPlantSection: String
        let plantNamePlaceholder: String
        let growthCycleFormat: String    // String(format:, days)
        let seedingDateLabel: String
        let importedActivitiesSection: String
        let searchingLabel: String
        let addPlantNavTitle: String
        let cannotSaveNoOrto: String
        let addedSuccessFormat: String   // String(format:, name)
        let enterPlantName: String
        let savedTitle: String
        let newActivityNavTitle: String
        let activityDetailsSection: String
        let activityNamePlaceholder: String
        let activityTypePicker: String
        let recurringType: String
        let oneOffType: String
        let intervalSection: String
        let everyNDaysFormat: String     // String(format:, days)
        let afterNDaysFormat: String     // String(format:, days)
        let addButton: String
        let editActivitiesNavTitle: String
        let noScheduledActivities: String
        let editIntervalNavTitle: String
        let restoreDefault: String
        let newHarvestNavTitle: String
        let datePicker: String
        let quantityLabel: String
        let quantityPlaceholder: String
        let unitPicker: String
        let optionalNotesPlaceholder: String
        let saveFailedMsg: String
    }

    struct GardenStrings {
        let navTitle: String
        let emptyTitle: String
        let emptyDesc: String
        let newGardenButton: String
        let gardenDetailsSection: String
        let gardenNamePlaceholder: String
        let locationSection: String
        let citySearchPlaceholder: String
        let useCurrentLocation: String
        let detectingGPS: String
        let deleteConfirmMsgFormat: String  // String(format:, gardenName)
        let deleteTitle: String
        let deleteButton: String
        let editNavTitle: String
        let deleteOrtoButton: String
        let plantsSection: String
        let emptyFirstPlant: String
        let addPlantButton: String
        let editButton: String
        let newOrtoNavTitle: String
    }

    struct JournalStrings {
        let navTitle: String
        let stepPlant: String
        let stepAction: String
        let stepDetails: String
        let noPlantsTitle: String
        let noPlantsDesc: String
        let nextButton: String
        let sectionPlant: String
        let sectionAction: String
        let sectionDate: String
        let dateEventLabel: String
        let sectionNote: String
        let saveEntryButton: String
        let savedSuccess: String
    }

    struct NotificationsStrings {
        let dailyTitle: String
        let andMore: String
        let activitiesCountFormat: String  // String(format:, count, summary, extra)
    }

    struct TabsStrings {
        let calendar: String
        let gardens: String
        let settings: String
    }

    let common:        Common
    let auth:          Auth
    let settings:      SettingsStrings
    let calendar:      CalendarStrings
    let dayDetail:     DayDetailStrings
    let plants:        PlantsStrings
    let garden:        GardenStrings
    let journal:       JournalStrings
    let notifications: NotificationsStrings
    let tabs:          TabsStrings
}

// MARK: - Italian

extension Strings {
    static let italian = Strings(
        common: Common(
            cancel: "Annulla", save: "Salva", confirm: "Conferma",
            delete: "Elimina", edit: "Modifica", add: "Aggiungi",
            error: "Errore", ok: "OK", next: "Avanti", retry: "Riprova"
        ),
        auth: Auth(
            appSubtitle: "Il tuo diario di giardinaggio intelligente",
            loginCardTitle: "Accedi",
            loginButton: "Accedi",
            signUpLink: "Non hai un account? **Registrati**",
            forgotPassword: "Password dimenticata?",
            orSeparator: "oppure",
            appleSignIn: "Accedi con Apple",
            appleSignInComingSoon: "Apple Sign-In sarà disponibile a breve.",
            resetTitle: "Password dimenticata",
            resetMessage: "Riceverai un'email per reimpostare la password.",
            resetEmailPlaceholder: "Inserisci la tua email",
            resetSentTitle: "Email inviata",
            resetSentMessage: "Controlla la tua casella di posta per reimpostare la password.",
            errorTitle: "Errore",
            errorUnknown: "Si è verificato un errore sconosciuto.",
            signUpTitle: "Crea il tuo account",
            signUpNavTitle: "Registrazione",
            signUpButton: "Registrati",
            loginLink: "Hai già un account? **Accedi**",
            emailInvalidError: "Inserisci un indirizzo email valido",
            passwordMinError: "Minimo 6 caratteri",
            passwordMatchError: "Le password non coincidono",
            registrationSuccessTitle: "Registrazione completata",
            registrationSuccessMessage: "Controlla la tua email per confermare l'account."
        ),
        settings: SettingsStrings(
            navTitle: "Impostazioni",
            profileSection: "Profilo",
            logoutButton: "Esci",
            logoutConfirmTitle: "Esci dall'account",
            logoutConfirmMsg: "Sei sicuro di voler uscire? Dovrai accedere nuovamente per usare l'app.",
            preferredGardenSection: "Orto preferito",
            defaultGardenPicker: "Orto predefinito",
            weatherSection: "Meteo",
            weatherPlaceholder: "Luogo (es. Roma)",
            rainThresholdLabel: "Soglia pioggia: %.0f mm",
            rainFooter: "La soglia di pioggia determina quando mostrare l'icona della pioggia nel calendario.",
            notificationsSection: "Notifiche",
            dailyReminderToggle: "Promemoria giornaliero",
            reminderHourPicker: "Ora del promemoria",
            notifFooter: "Ricevi ogni mattina un promemoria con le attività del giorno.",
            notifDeniedTitle: "Notifiche disattivate",
            notifDeniedMsg: "Abilita le notifiche per Garden Calendar in Impostazioni di iOS per ricevere i promemoria.",
            appearanceSection: "Aspetto",
            themePicker: "Tema",
            themeLight: "🌞 Chiaro",
            themeDark: "🌙 Scuro",
            themeAuto: "🔄 Automatico",
            languageSection: "Lingua",
            languagePickerLabel: "Lingua / Language",
            infoSection: "Info",
            versionLabel: "Versione",
            builtWithLabel: "Sviluppata con",
            deleteAccountButton: "Elimina account",
            deleteAccountFooter: "L'eliminazione dell'account cancellerà tutti i tuoi dati. Questa azione è irreversibile.",
            deleteConfirmTitle: "Elimina account",
            deleteConfirmMsg: "Questa azione è irreversibile. Tutti i tuoi dati verranno cancellati permanentemente.",
            deleteConfirmPlaceholder: "Scrivi 'ELIMINA' per confermare",
            deleteConfirmKeyword: "ELIMINA",
            deleteConfirmButton: "Elimina definitivamente",
            deletedTitle: "Account eliminato",
            deletedMsg: "Il tuo account e tutti i dati associati sono stati eliminati."
        ),
        calendar: CalendarStrings(
            navTitle: "Calendario",
            todayButton: "Oggi",
            viewCalendar: "Calendario",
            viewAgenda: "Agenda",
            weekDays: ["L", "M", "M", "G", "V", "S", "D"],
            filterAllGardens: "Tutti gli orti",
            filterAllTypes: "Tutte le tipologie",
            filterAllPlants: "Tutte le piante",
            filterGardenDefault: "Orto",
            filterTypeDefault: "Tipologia",
            filterPlantDefault: "Pianta",
            offlineBanner: "Sei offline: dati salvati sul dispositivo",
            rainToastSingular: "1 irrigazione spostata per pioggia",
            rainToastPlural: "%d irrigazioni spostate per pioggia",
            noActivitiesAgenda: "Nessuna attività in programma",
            legendSeedTransplant: "Semina / Trapianto",
            legendHarvest: "Raccolta",
            legendWatering: "Irrigazione",
            legendTreatment: "Trattamento",
            legendPruning: "Potatura / Sarchiatura",
            legendReminder: "Promemoria",
            todayLabel: "Oggi"
        ),
        dayDetail: DayDetailStrings(
            activitiesTitle: "Attività del giorno",
            noActivitiesDay: "Nessuna attività per questo giorno",
            addActivity: "Aggiungi attività",
            rainMmFormat: "%.0f mm di pioggia",
            frostFormat: "Rischio gelata: min %.0f°C",
            swipeForward: "Sposta",
            swipeBack: "Indietro",
            rescheduleTitle: "Reschedule",
            rescheduleSection: "Sposta attività",
            newDateLabel: "Nuova data",
            rescheduleConfirm: "Conferma spostamento",
            dateLocale: "it_IT"
        ),
        plants: PlantsStrings(
            navTitle: "Piante",
            searchPlaceholder: "Cerca piante...",
            emptyTitle: "Nessuna pianta trovata",
            emptyDesc: "Aggiungi la tua prima pianta per iniziare a tracciarla.",
            addPlantButton: "Aggiungi pianta",
            totalDaysFormat: "%d giorni totali",
            activitiesCountFormat: "%d attività",
            editButton: "Modifica",
            scheduledSection: "In programma",
            pastSection: "Completate / Passate",
            noActivitiesPlant: "Nessuna attività registrata per questa pianta.",
            activitiesSectionTitle: "📋 Attività",
            harvestSectionTitle: "🧺 Raccolti",
            noHarvests: "Nessun raccolto registrato. Tocca + per annotare il primo!",
            completedLabel: "Completato! 🎉",
            recurringLabel: "Ricorrente",
            catalogSection: "Dal catalogo",
            catalogSearchPlaceholder: "Cerca nel catalogo...",
            customPlantSection: "Pianta personalizzata",
            plantNamePlaceholder: "Nome pianta",
            growthCycleFormat: "Ciclo crescita: %d giorni",
            seedingDateLabel: "Data semina",
            importedActivitiesSection: "Attività importate dal catalogo",
            searchingLabel: "Ricerca in corso...",
            addPlantNavTitle: "Aggiungi pianta",
            cannotSaveNoOrto: "Impossibile salvare: apri questa schermata da un orto specifico.",
            addedSuccessFormat: "%@ aggiunta con successo!",
            enterPlantName: "Inserisci un nome per la pianta.",
            savedTitle: "Salvato",
            newActivityNavTitle: "Nuova attività",
            activityDetailsSection: "Dettagli attività",
            activityNamePlaceholder: "Es. irrigazione, concimazione…",
            activityTypePicker: "Tipo",
            recurringType: "Ricorrente",
            oneOffType: "Una tantum",
            intervalSection: "Intervallo",
            everyNDaysFormat: "Ogni %d giorni",
            afterNDaysFormat: "Dopo %d giorni dalla semina",
            addButton: "Aggiungi",
            editActivitiesNavTitle: "Modifica attività",
            noScheduledActivities: "Nessuna attività programmata.",
            editIntervalNavTitle: "Modifica intervallo",
            restoreDefault: "Ripristina default",
            newHarvestNavTitle: "Nuovo raccolto",
            datePicker: "Data",
            quantityLabel: "Quantità",
            quantityPlaceholder: "Quantità",
            unitPicker: "Unità",
            optionalNotesPlaceholder: "Note (facoltative)",
            saveFailedMsg: "Salvataggio non riuscito. Controlla la connessione e riprova."
        ),
        garden: GardenStrings(
            navTitle: "I miei orti",
            emptyTitle: "Crea il tuo primo orto",
            emptyDesc: "Organizza le tue piante in orti e giardini per tenerle sotto controllo.",
            newGardenButton: "Nuovo orto",
            gardenDetailsSection: "Dettagli orto",
            gardenNamePlaceholder: "Nome orto",
            locationSection: "Posizione",
            citySearchPlaceholder: "Cerca città...",
            useCurrentLocation: "Usa posizione attuale",
            detectingGPS: "Rilevamento GPS...",
            deleteConfirmMsgFormat: "Eliminare l'orto \"%@\"? Le piante collegate non verranno eliminate.",
            deleteTitle: "Elimina orto",
            deleteButton: "Elimina",
            editNavTitle: "Modifica orto",
            deleteOrtoButton: "Elimina orto",
            plantsSection: "Piante",
            emptyFirstPlant: "Aggiungi la tua prima pianta",
            addPlantButton: "Aggiungi pianta",
            editButton: "Modifica",
            newOrtoNavTitle: "Nuovo orto"
        ),
        journal: JournalStrings(
            navTitle: "Nuovo Journal Entry",
            stepPlant: "Pianta",
            stepAction: "Azione",
            stepDetails: "Dettagli",
            noPlantsTitle: "Nessuna pianta",
            noPlantsDesc: "Aggiungi prima una pianta per poter registrare eventi.",
            nextButton: "Avanti",
            sectionPlant: "Pianta",
            sectionAction: "Azione",
            sectionDate: "Data",
            dateEventLabel: "Data evento",
            sectionNote: "Nota (opzionale)",
            saveEntryButton: "Salva Journal Entry",
            savedSuccess: "Evento salvato con successo! ✅"
        ),
        notifications: NotificationsStrings(
            dailyTitle: "🌱 Attività di oggi nell'orto",
            andMore: " e altre",
            activitiesCountFormat: "%d attività: %@%@"
        ),
        tabs: TabsStrings(
            calendar: "Calendario",
            gardens: "Orti",
            settings: "Impostazioni"
        )
    )
}

// MARK: - English

extension Strings {
    static let english = Strings(
        common: Common(
            cancel: "Cancel", save: "Save", confirm: "Confirm",
            delete: "Delete", edit: "Edit", add: "Add",
            error: "Error", ok: "OK", next: "Next", retry: "Retry"
        ),
        auth: Auth(
            appSubtitle: "Your smart gardening journal",
            loginCardTitle: "Sign In",
            loginButton: "Sign In",
            signUpLink: "Don't have an account? **Sign Up**",
            forgotPassword: "Forgot password?",
            orSeparator: "or",
            appleSignIn: "Sign in with Apple",
            appleSignInComingSoon: "Apple Sign-In coming soon.",
            resetTitle: "Forgot password",
            resetMessage: "You'll receive an email to reset your password.",
            resetEmailPlaceholder: "Enter your email",
            resetSentTitle: "Email sent",
            resetSentMessage: "Check your inbox to reset your password.",
            errorTitle: "Error",
            errorUnknown: "An unknown error occurred.",
            signUpTitle: "Create your account",
            signUpNavTitle: "Sign Up",
            signUpButton: "Sign Up",
            loginLink: "Already have an account? **Sign In**",
            emailInvalidError: "Enter a valid email address",
            passwordMinError: "Minimum 6 characters",
            passwordMatchError: "Passwords don't match",
            registrationSuccessTitle: "Registration complete",
            registrationSuccessMessage: "Check your email to confirm your account."
        ),
        settings: SettingsStrings(
            navTitle: "Settings",
            profileSection: "Profile",
            logoutButton: "Sign Out",
            logoutConfirmTitle: "Sign Out",
            logoutConfirmMsg: "Are you sure you want to sign out? You'll need to sign in again to use the app.",
            preferredGardenSection: "Preferred garden",
            defaultGardenPicker: "Default garden",
            weatherSection: "Weather",
            weatherPlaceholder: "Location (e.g. Rome)",
            rainThresholdLabel: "Rain threshold: %.0f mm",
            rainFooter: "The rain threshold determines when to show the rain icon in the calendar.",
            notificationsSection: "Notifications",
            dailyReminderToggle: "Daily reminder",
            reminderHourPicker: "Reminder time",
            notifFooter: "Receive a morning reminder with today's activities.",
            notifDeniedTitle: "Notifications disabled",
            notifDeniedMsg: "Enable notifications for Garden Calendar in iOS Settings to receive reminders.",
            appearanceSection: "Appearance",
            themePicker: "Theme",
            themeLight: "🌞 Light",
            themeDark: "🌙 Dark",
            themeAuto: "🔄 Automatic",
            languageSection: "Language",
            languagePickerLabel: "Language / Lingua",
            infoSection: "Info",
            versionLabel: "Version",
            builtWithLabel: "Built with",
            deleteAccountButton: "Delete account",
            deleteAccountFooter: "Deleting your account will erase all your data. This action is irreversible.",
            deleteConfirmTitle: "Delete account",
            deleteConfirmMsg: "This action is irreversible. All your data will be permanently deleted.",
            deleteConfirmPlaceholder: "Type 'DELETE' to confirm",
            deleteConfirmKeyword: "DELETE",
            deleteConfirmButton: "Delete permanently",
            deletedTitle: "Account deleted",
            deletedMsg: "Your account and all associated data have been deleted."
        ),
        calendar: CalendarStrings(
            navTitle: "Calendar",
            todayButton: "Today",
            viewCalendar: "Calendar",
            viewAgenda: "Agenda",
            weekDays: ["M", "T", "W", "T", "F", "S", "S"],
            filterAllGardens: "All gardens",
            filterAllTypes: "All types",
            filterAllPlants: "All plants",
            filterGardenDefault: "Garden",
            filterTypeDefault: "Type",
            filterPlantDefault: "Plant",
            offlineBanner: "Offline: showing cached data",
            rainToastSingular: "1 watering moved due to rain",
            rainToastPlural: "%d waterings moved due to rain",
            noActivitiesAgenda: "No activities scheduled",
            legendSeedTransplant: "Sowing / Transplant",
            legendHarvest: "Harvest",
            legendWatering: "Watering",
            legendTreatment: "Treatment",
            legendPruning: "Pruning / Weeding",
            legendReminder: "Reminder",
            todayLabel: "Today"
        ),
        dayDetail: DayDetailStrings(
            activitiesTitle: "Today's activities",
            noActivitiesDay: "No activities for this day",
            addActivity: "Add activity",
            rainMmFormat: "%.0f mm of rain",
            frostFormat: "Frost risk: min %.0f°C",
            swipeForward: "Move",
            swipeBack: "Back",
            rescheduleTitle: "Reschedule",
            rescheduleSection: "Move activity",
            newDateLabel: "New date",
            rescheduleConfirm: "Confirm move",
            dateLocale: "en_US"
        ),
        plants: PlantsStrings(
            navTitle: "Plants",
            searchPlaceholder: "Search plants...",
            emptyTitle: "No plants found",
            emptyDesc: "Add your first plant to start tracking it.",
            addPlantButton: "Add plant",
            totalDaysFormat: "%d total days",
            activitiesCountFormat: "%d activities",
            editButton: "Edit",
            scheduledSection: "Scheduled",
            pastSection: "Completed / Past",
            noActivitiesPlant: "No activities registered for this plant.",
            activitiesSectionTitle: "📋 Activities",
            harvestSectionTitle: "🧺 Harvests",
            noHarvests: "No harvests recorded. Tap + to log the first one!",
            completedLabel: "Completed! 🎉",
            recurringLabel: "Recurring",
            catalogSection: "From catalog",
            catalogSearchPlaceholder: "Search catalog...",
            customPlantSection: "Custom plant",
            plantNamePlaceholder: "Plant name",
            growthCycleFormat: "Growth cycle: %d days",
            seedingDateLabel: "Sowing date",
            importedActivitiesSection: "Activities imported from catalog",
            searchingLabel: "Searching...",
            addPlantNavTitle: "Add plant",
            cannotSaveNoOrto: "Cannot save: open this screen from a specific garden.",
            addedSuccessFormat: "%@ added successfully!",
            enterPlantName: "Enter a plant name.",
            savedTitle: "Saved",
            newActivityNavTitle: "New activity",
            activityDetailsSection: "Activity details",
            activityNamePlaceholder: "E.g. watering, fertilizing…",
            activityTypePicker: "Type",
            recurringType: "Recurring",
            oneOffType: "One-time",
            intervalSection: "Interval",
            everyNDaysFormat: "Every %d days",
            afterNDaysFormat: "After %d days from sowing",
            addButton: "Add",
            editActivitiesNavTitle: "Edit activities",
            noScheduledActivities: "No activities scheduled.",
            editIntervalNavTitle: "Edit interval",
            restoreDefault: "Restore default",
            newHarvestNavTitle: "New harvest",
            datePicker: "Date",
            quantityLabel: "Quantity",
            quantityPlaceholder: "Quantity",
            unitPicker: "Unit",
            optionalNotesPlaceholder: "Notes (optional)",
            saveFailedMsg: "Save failed. Check your connection and try again."
        ),
        garden: GardenStrings(
            navTitle: "My gardens",
            emptyTitle: "Create your first garden",
            emptyDesc: "Organize your plants in gardens to keep track of them.",
            newGardenButton: "New garden",
            gardenDetailsSection: "Garden details",
            gardenNamePlaceholder: "Garden name",
            locationSection: "Location",
            citySearchPlaceholder: "Search city...",
            useCurrentLocation: "Use current location",
            detectingGPS: "Detecting GPS...",
            deleteConfirmMsgFormat: "Delete garden \"%@\"? Associated plants won't be deleted.",
            deleteTitle: "Delete garden",
            deleteButton: "Delete",
            editNavTitle: "Edit garden",
            deleteOrtoButton: "Delete garden",
            plantsSection: "Plants",
            emptyFirstPlant: "Add your first plant",
            addPlantButton: "Add plant",
            editButton: "Edit",
            newOrtoNavTitle: "New garden"
        ),
        journal: JournalStrings(
            navTitle: "New Journal Entry",
            stepPlant: "Plant",
            stepAction: "Action",
            stepDetails: "Details",
            noPlantsTitle: "No plants",
            noPlantsDesc: "Add a plant first to record events.",
            nextButton: "Next",
            sectionPlant: "Plant",
            sectionAction: "Action",
            sectionDate: "Date",
            dateEventLabel: "Event date",
            sectionNote: "Note (optional)",
            saveEntryButton: "Save Journal Entry",
            savedSuccess: "Event saved successfully! ✅"
        ),
        notifications: NotificationsStrings(
            dailyTitle: "🌱 Today's garden activities",
            andMore: " and more",
            activitiesCountFormat: "%d activities: %@%@"
        ),
        tabs: TabsStrings(
            calendar: "Calendar",
            gardens: "Gardens",
            settings: "Settings"
        )
    )
}

// MARK: - LanguageManager

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

    var common:        Strings.Common             { strings.common }
    var auth:          Strings.Auth               { strings.auth }
    var settings:      Strings.SettingsStrings    { strings.settings }
    var calendar:      Strings.CalendarStrings    { strings.calendar }
    var dayDetail:     Strings.DayDetailStrings   { strings.dayDetail }
    var plants:        Strings.PlantsStrings      { strings.plants }
    var garden:        Strings.GardenStrings      { strings.garden }
    var journal:       Strings.JournalStrings     { strings.journal }
    var notifications: Strings.NotificationsStrings { strings.notifications }
    var tabs:          Strings.TabsStrings        { strings.tabs }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "it"
        let lang = AppLanguage(rawValue: saved) ?? .it
        self.language = lang
        self.strings = lang.strings
    }
}
```

- [ ] **Step 2: Compilare il progetto e verificare che non ci siano errori**

Apri Xcode e build (`Cmd+B`). Il file non referenzia ancora nessun tipo esterno, deve compilare senza errori.

- [ ] **Step 3: Commit**

```bash
git add "GardenCalendar/Localization/Strings.swift"
git commit -m "feat: add Strings + LanguageManager for IT/EN localization"
```

---

## Task 2: Iniettare `LanguageManager` in root + aggiornare `ContentView`

**Files:**
- Modify: `GardenCalendar/GardenCalendarApp.swift`
- Modify: `GardenCalendar/ContentView.swift`

- [ ] **Step 1: Aggiungere `LanguageManager` all'environment in `GardenCalendarApp.swift`**

Aggiungi dopo `@State private var repository = SupabaseRepository.shared`:
```swift
@State private var langManager = LanguageManager.shared
```

Aggiungi `.environment(langManager)` nella catena dopo `.environment(repository)`:
```swift
ContentView()
    .environment(authManager)
    .environment(repository)
    .environment(langManager)
```

- [ ] **Step 2: Localizzare le tab label in `ContentView.swift`**

Aggiungi `@Environment(LanguageManager.self) var lang` all'inizio di `ContentView`.

Sostituisci le tre label delle tab:
```swift
// prima:
Label("Calendario", systemImage: "calendar")
Label("Orti", systemImage: "leaf")
Label("Impostazioni", systemImage: "gearshape")

// dopo:
Label(lang.tabs.calendar, systemImage: "calendar")
Label(lang.tabs.gardens, systemImage: "leaf")
Label(lang.tabs.settings, systemImage: "gearshape")
```

Aggiungi anche `ProgressView("Caricamento…")` → `ProgressView(lang.common.next)` — no, `ProgressView` qui non è localizzabile facilmente senza un label apposito. Lascia invariato per ora.

- [ ] **Step 3: Build + commit**

```bash
git add GardenCalendar/GardenCalendarApp.swift GardenCalendar/ContentView.swift
git commit -m "feat(l10n): inject LanguageManager, localize tab labels"
```

---

## Task 3: Aggiornare `SettingsView.swift`

**Files:**
- Modify: `GardenCalendar/Views/Settings/SettingsView.swift`

- [ ] **Step 1: Aggiungere environment e stato lingua**

In testa alla struct, dopo gli `@State` esistenti, aggiungi:
```swift
@Environment(LanguageManager.self) private var lang
```

- [ ] **Step 2: Aggiungere sezione Lingua prima di "Aspetto"**

Subito prima di `// MARK: - Aspetto`, inserisci:
```swift
// MARK: - Lingua
Section(header: sectionHeader(lang.settings.languageSection)) {
    Picker(lang.settings.languagePickerLabel, selection: Binding(
        get: { lang.language },
        set: { lang.language = $0 }
    )) {
        ForEach(AppLanguage.allCases, id: \.self) { l in
            Text(l.displayName).tag(l)
        }
    }
    .pickerStyle(.menu)
    .font(.dmSans(15))
    .listRowBackground(AppTheme.cardBackground)
}
```

Nota: `lang.language` è `private(set)` — per il Binding serve accedere a `LanguageManager.shared` direttamente o rendere `language` settabile. Poiché `@Observable` non espone setter via `@Environment`, usa:
```swift
Picker(lang.settings.languagePickerLabel, selection: Binding(
    get: { LanguageManager.shared.language },
    set: { LanguageManager.shared.language = $0 }
)) {
```
Rimuovi `private(set)` da `var language` in `LanguageManager` per consentire il set esterno.

- [ ] **Step 3: Sostituire tutte le stringhe hardcoded**

Applica le seguenti sostituzioni (mostra solo i valori stringa, il resto del codice rimane uguale):

| Stringa originale | Sostituzione |
|---|---|
| `sectionHeader("Profilo")` | `sectionHeader(lang.settings.profileSection)` |
| `Label("Esci", ...)` | `Label(lang.settings.logoutButton, ...)` |
| `sectionHeader("Orto preferito")` | `sectionHeader(lang.settings.preferredGardenSection)` |
| `Picker("Orto predefinito", ...)` | `Picker(lang.settings.defaultGardenPicker, ...)` |
| `sectionHeader("Meteo")` | `sectionHeader(lang.settings.weatherSection)` |
| footer `"La soglia di pioggia…"` | `Text(lang.settings.rainFooter)` |
| `TextField("Luogo (es. Roma)", ...)` | `TextField(lang.settings.weatherPlaceholder, ...)` |
| `Text("Soglia pioggia: \(rainThreshold, specifier: "%.0f") mm")` | `Text(String(format: lang.settings.rainThresholdLabel, rainThreshold))` |
| `sectionHeader("Notifiche")` | `sectionHeader(lang.settings.notificationsSection)` |
| footer `"Ricevi ogni mattina…"` | `Text(lang.settings.notifFooter)` |
| `Label("Promemoria giornaliero", ...)` | `Label(lang.settings.dailyReminderToggle, ...)` |
| `Picker("Ora del promemoria", ...)` | `Picker(lang.settings.reminderHourPicker, ...)` |
| `sectionHeader("Aspetto")` | `sectionHeader(lang.settings.appearanceSection)` |
| `Picker("Tema", ...)` | `Picker(lang.settings.themePicker, ...)` |
| `Text("🌞 Chiaro")` | `Text(lang.settings.themeLight)` |
| `Text("🌙 Scuro")` | `Text(lang.settings.themeDark)` |
| `Text("🔄 Automatico")` | `Text(lang.settings.themeAuto)` |
| `sectionHeader("Info")` | `sectionHeader(lang.settings.infoSection)` |
| `Text("Versione")` | `Text(lang.settings.versionLabel)` |
| `Text("Sviluppata con")` | `Text(lang.settings.builtWithLabel)` |
| `Label("Elimina account", ...)` | `Label(lang.settings.deleteAccountButton, ...)` |
| footer `"L'eliminazione dell'account…"` | `Text(lang.settings.deleteAccountFooter)` |
| `.navigationTitle("Impostazioni")` | `.navigationTitle(lang.settings.navTitle)` |
| `.alert("Esci dall'account", ...)` | `.alert(lang.settings.logoutConfirmTitle, ...)` |
| `Button("Esci", role: .destructive)` (dentro alert) | `Button(lang.settings.logoutButton, role: .destructive)` |
| `Button("Annulla", role: .cancel)` | `Button(lang.common.cancel, role: .cancel)` |
| message `"Sei sicuro di voler uscire…"` | `Text(lang.settings.logoutConfirmMsg)` |
| `.alert("Elimina account", isPresented: $showDeleteConfirm)` | `.alert(lang.settings.deleteConfirmTitle, ...)` |
| `TextField("Scrivi 'ELIMINA' per confermare", ...)` | `TextField(lang.settings.deleteConfirmPlaceholder, ...)` |
| `.disabled(deleteConfirmText != "ELIMINA")` | `.disabled(deleteConfirmText != lang.settings.deleteConfirmKeyword)` |
| `Button("Elimina definitivamente", ...)` | `Button(lang.settings.deleteConfirmButton, ...)` |
| message `"Questa azione è irreversibile…"` | `Text(lang.settings.deleteConfirmMsg)` |
| `.alert("Notifiche disattivate", ...)` | `.alert(lang.settings.notifDeniedTitle, ...)` |
| message `"Abilita le notifiche…"` | `Text(lang.settings.notifDeniedMsg)` |
| `.alert("Account eliminato", ...)` | `.alert(lang.settings.deletedTitle, ...)` |
| message `"Il tuo account e tutti…"` | `Text(lang.settings.deletedMsg)` |

- [ ] **Step 4: Build + commit**

```bash
git add "GardenCalendar/Views/Settings/SettingsView.swift" GardenCalendar/Localization/Strings.swift
git commit -m "feat(l10n): localize SettingsView, add language picker"
```

---

## Task 4: Aggiornare `LoginView.swift` e `SignUpView.swift`

**Files:**
- Modify: `GardenCalendar/Views/Auth/LoginView.swift`
- Modify: `GardenCalendar/Views/Auth/SignUpView.swift`

- [ ] **Step 1: `LoginView.swift` — aggiungere environment e sostituire stringhe**

Aggiungi in testa alla struct:
```swift
@Environment(LanguageManager.self) private var lang
```

Sostituzioni:
| Originale | Sostituzione |
|---|---|
| `Text("Il tuo diario di giardinaggio intelligente")` | `Text(lang.auth.appSubtitle)` |
| `Text("Accedi")` (titolo card) | `Text(lang.auth.loginCardTitle)` |
| `Text("Accedi")` (bottone) | `Text(lang.auth.loginButton)` |
| `Text("Non hai un account? **Registrati**")` | `Text(.init(lang.auth.signUpLink))` |
| `Text("Password dimenticata?")` | `Text(lang.auth.forgotPassword)` |
| `Text("oppure")` | `Text(lang.auth.orSeparator)` |
| `Label("Accedi con Apple", ...)` | `Label(lang.auth.appleSignIn, ...)` |
| `.alert("Password dimenticata", ...)` | `.alert(lang.auth.resetTitle, ...)` |
| `TextField("Inserisci la tua email", ...)` | `TextField(lang.auth.resetEmailPlaceholder, ...)` |
| `Button("Invia")` | `Button(lang.auth.resetButton)` dove `resetButton` va aggiunto a `Auth` struct come `let resetButton: String` con valore "Invia"/"Send" |
| `Button("Annulla", role: .cancel)` | `Button(lang.common.cancel, role: .cancel)` |
| message `"Riceverai un'email…"` | `Text(lang.auth.resetMessage)` |
| `.alert("Errore", ...)` | `.alert(lang.auth.errorTitle, ...)` |
| message `errorMessage ?? "Si è verificato un errore sconosciuto."` | `Text(errorMessage ?? lang.auth.errorUnknown)` |
| `.alert("Email inviata", ...)` | `.alert(lang.auth.resetSentTitle, ...)` |
| message `"Controlla la tua casella…"` | `Text(lang.auth.resetSentMessage)` |
| `errorMessage = "Apple Sign-In sarà disponibile a breve."` | `errorMessage = lang.auth.appleSignInComingSoon` |

Aggiungere `let resetButton: String` alla struct `Auth` in `Strings.swift`: IT = `"Invia"`, EN = `"Send"`.

Nota: `Text("Non hai un account? **Registrati**")` — SwiftUI renderizza il markdown se si usa `Text(.init(string))`. Mantieni il pattern.

- [ ] **Step 2: `SignUpView.swift` — aggiungere environment e sostituire stringhe**

Aggiungi in testa:
```swift
@Environment(LanguageManager.self) private var lang
```

Sostituzioni:
| Originale | Sostituzione |
|---|---|
| `Text("Crea il tuo account")` | `Text(lang.auth.signUpTitle)` |
| `Text("Inserisci un indirizzo email valido")` | `Text(lang.auth.emailInvalidError)` |
| `Text("Minimo 6 caratteri")` | `Text(lang.auth.passwordMinError)` |
| `SecureField("Conferma password", ...)` | `SecureField(lang.auth.confirmPasswordPlaceholder, ...)` |
| `Text("Le password non coincidono")` | `Text(lang.auth.passwordMatchError)` |
| `Text("Registrati")` (bottone) | `Text(lang.auth.signUpButton)` |
| `Text("Hai già un account? **Accedi**")` | `Text(.init(lang.auth.loginLink))` |
| `.navigationTitle("Registrazione")` | `.navigationTitle(lang.auth.signUpNavTitle)` |
| `.alert("Errore", ...)` | `.alert(lang.auth.errorTitle, ...)` |
| `Button("OK", role: .cancel)` | `Button(lang.common.ok, role: .cancel)` |
| message `errorMessage ?? "Si è verificato un errore."` | `Text(errorMessage ?? lang.auth.errorUnknown)` |
| `.alert("Registrazione completata", ...)` | `.alert(lang.auth.registrationSuccessTitle, ...)` |
| message `"Controlla la tua email…"` | `Text(lang.auth.registrationSuccessMessage)` |

- [ ] **Step 3: Aggiungere `resetButton` a `Strings.swift`**

In `struct Auth`, aggiungi `let resetButton: String`.
In `Strings.italian.auth`: `resetButton: "Invia"`.
In `Strings.english.auth`: `resetButton: "Send"`.

- [ ] **Step 4: Build + commit**

```bash
git add GardenCalendar/Views/Auth/LoginView.swift GardenCalendar/Views/Auth/SignUpView.swift GardenCalendar/Localization/Strings.swift
git commit -m "feat(l10n): localize LoginView and SignUpView"
```

---

## Task 5: Aggiornare `CalendarView.swift`

**Files:**
- Modify: `GardenCalendar/Views/Calendario/CalendarView.swift`

- [ ] **Step 1: Aggiungere environment**

Aggiungere tra le property `@State`:
```swift
@Environment(LanguageManager.self) private var lang
```

- [ ] **Step 2: Cambiare `ViewMode` rawValues e label**

Trovare la definizione di `ViewMode` (circa riga 43) e cambiarla:
```swift
// prima:
enum ViewMode: String, CaseIterable {
    case calendar = "Calendario"
    case agenda = "Agenda"
}

// dopo:
enum ViewMode: String, CaseIterable {
    case calendar = "calendar"
    case agenda = "agenda"
}
```

Poi nel metodo `pillSegmentButton` (circa riga 195), cambiare `Text(mode.rawValue)` in:
```swift
Text(mode == .calendar ? lang.calendar.viewCalendar : lang.calendar.viewAgenda)
```

- [ ] **Step 3: Trasformare `tipologie` da `let` a `var` computed**

Trovare (circa riga 32-40):
```swift
private let weekDays = ["L", "M", "M", "G", "V", "S", "D"]
// ...
private let tipologie: [(color: String, label: String)] = [
    ("green",  "Semina / Trapianto"),
    ("orange", "Raccolta"),
    ("blue",   "Irrigazione"),
    ("red",    "Trattamento"),
    ("gray",   "Potatura / Sarchiatura"),
    ("purple", "Promemoria"),
]
```

Sostituire con computed properties:
```swift
private var weekDays: [String] { lang.calendar.weekDays }

private var tipologie: [(color: String, label: String)] {
    [
        ("green",  lang.calendar.legendSeedTransplant),
        ("orange", lang.calendar.legendHarvest),
        ("blue",   lang.calendar.legendWatering),
        ("red",    lang.calendar.legendTreatment),
        ("gray",   lang.calendar.legendPruning),
        ("purple", lang.calendar.legendReminder),
    ]
}
```

- [ ] **Step 4: Sostituire tutte le stringhe hardcoded nel body**

| Originale | Sostituzione |
|---|---|
| `.navigationTitle("Calendario")` | `.navigationTitle(lang.calendar.navTitle)` |
| `Button("Oggi")` (toolbar) | `Button(lang.calendar.todayButton)` |
| `Text("Sei offline: dati salvati sul dispositivo")` | `Text(lang.calendar.offlineBanner)` |
| `Button("Riprova")` (entrambe le occorrenze) | `Button(lang.common.retry)` |
| `Button("Tutti gli orti")` | `Button(lang.calendar.filterAllGardens)` |
| `Button("Tutte le tipologie")` | `Button(lang.calendar.filterAllTypes)` |
| `Button("Tutte le piante")` | `Button(lang.calendar.filterAllPlants)` |
| `?? "Orto"` (filterChip default) | `?? lang.calendar.filterGardenDefault` |
| `?? "Tipologia"` | `?? lang.calendar.filterTypeDefault` |
| `?? "Pianta"` | `?? lang.calendar.filterPlantDefault` |
| `Text("Nessuna attività in programma")` | `Text(lang.calendar.noActivitiesAgenda)` |
| `if isToday { label = "Oggi" }` | `if isToday { label = lang.calendar.todayLabel }` |

Per il rain toast (circa riga 174):
```swift
// prima:
Text("\(rainRescheduledCount) irrigazion\(rainRescheduledCount == 1 ? "e" : "i") spostat\(rainRescheduledCount == 1 ? "a" : "e") per pioggia")

// dopo:
Text(rainRescheduledCount == 1
    ? lang.calendar.rainToastSingular
    : String(format: lang.calendar.rainToastPlural, rainRescheduledCount))
```

Se esistono le stesse stringhe `tipologie` duplicate (linee ~440-445), sostituirle allo stesso modo — usando la stessa `var tipologie` computed property.

- [ ] **Step 5: Build + commit**

```bash
git add "GardenCalendar/Views/Calendario/CalendarView.swift"
git commit -m "feat(l10n): localize CalendarView, refactor ViewMode and tipologie"
```

---

## Task 6: Aggiornare `DayDetailSheet.swift`

**Files:**
- Modify: `GardenCalendar/Views/Calendario/DayDetailSheet.swift`

- [ ] **Step 1: Aggiungere environment**

Tra le property `@State` esistenti:
```swift
@Environment(LanguageManager.self) private var lang
```

- [ ] **Step 2: Sostituire stringhe**

| Originale | Sostituzione |
|---|---|
| `Text("Attività del giorno")` | `Text(lang.dayDetail.activitiesTitle)` |
| `Text("Nessuna attività per questo giorno")` | `Text(lang.dayDetail.noActivitiesDay)` |
| `Text("Aggiungi attività")` | `Text(lang.dayDetail.addActivity)` |
| `Text(String(format: "%.0f mm di pioggia", rainMm))` | `Text(String(format: lang.dayDetail.rainMmFormat, rainMm))` |
| `Text(String(format: "Rischio gelata: min %.0f°C", tMin))` | `Text(String(format: lang.dayDetail.frostFormat, tMin))` |
| `Label("Sposta", systemImage: ...)` (swipeAction) | `Label(lang.dayDetail.swipeForward, systemImage: ...)` |
| `Label("Indietro", systemImage: ...)` (swipeAction) | `Label(lang.dayDetail.swipeBack, systemImage: ...)` |
| `Section("Sposta attività")` | `Section(lang.dayDetail.rescheduleSection)` |
| `DatePicker("Nuova data", ...)` | `DatePicker(lang.dayDetail.newDateLabel, ...)` |
| `Text("Conferma spostamento")` | `Text(lang.dayDetail.rescheduleConfirm)` |
| `.navigationTitle("Reschedule")` | `.navigationTitle(lang.dayDetail.rescheduleTitle)` |
| `Button("Annulla")` | `Button(lang.common.cancel)` |

- [ ] **Step 3: Rendere `dateHeaderString` dinamico per locale**

Trovare `dateHeaderString` (circa riga 192):
```swift
// prima:
private var dateHeaderString: String {
    let f = DateFormatter()
    f.locale = Locale(identifier: "it_IT")
    f.dateFormat = "EEE · d MMMM yyyy"
    return f.string(from: selectedDate).uppercased()
}

// dopo:
private var dateHeaderString: String {
    let f = DateFormatter()
    f.locale = Locale(identifier: lang.dayDetail.dateLocale)
    f.dateFormat = "EEE · d MMMM yyyy"
    return f.string(from: selectedDate).uppercased()
}
```

- [ ] **Step 4: Build + commit**

```bash
git add "GardenCalendar/Views/Calendario/DayDetailSheet.swift"
git commit -m "feat(l10n): localize DayDetailView, dynamic date locale"
```

---

## Task 7: Aggiornare `PiantaListView.swift` e `PiantaDetailView.swift`

**Files:**
- Modify: `GardenCalendar/Views/Piante/PiantaListView.swift`
- Modify: `GardenCalendar/Views/Piante/PiantaDetailView.swift`

- [ ] **Step 1: `PiantaListView.swift`**

Aggiungi `@Environment(LanguageManager.self) private var lang` alla struct `PiantaListView`.

Aggiungi anche a `PiantaCardView` (struct interna nella stessa file):
```swift
@Environment(LanguageManager.self) private var lang
```

Sostituzioni in `PiantaListView`:
| Originale | Sostituzione |
|---|---|
| `TextField("Cerca piante...", ...)` | `TextField(lang.plants.searchPlaceholder, ...)` |
| `Label("Nessuna pianta trovata", ...)` (ContentUnavailableView title) | `Label(lang.plants.emptyTitle, ...)` |
| `Text("Aggiungi la tua prima pianta per iniziare a tracciarla.")` | `Text(lang.plants.emptyDesc)` |
| `Label("Aggiungi pianta", ...)` (action) | `Label(lang.plants.addPlantButton, ...)` |
| `.navigationTitle("Piante")` | `.navigationTitle(lang.plants.navTitle)` |

Sostituzioni in `PiantaCardView`:
| Originale | Sostituzione |
|---|---|
| `Text("\(pianta.growthDays) giorni totali")` | `Text(String(format: lang.plants.totalDaysFormat, pianta.growthDays))` |

- [ ] **Step 2: `PiantaDetailView.swift`**

Aggiungi `@Environment(LanguageManager.self) private var lang` a `PiantaDetailView`.

Aggiungi anche a `AttivitaRow`, `RaccoltoRow`, `NuovoRaccoltoSheet` (struct nella stessa file).

Sostituzioni in `PiantaDetailView`:
| Originale | Sostituzione |
|---|---|
| `Button("Modifica")` (toolbar) | `Button(lang.plants.editButton)` |
| `Label("\(attivita.count) attività", ...)` | `Label(String(format: lang.plants.activitiesCountFormat, attivita.count), ...)` |
| `Text("Completato! 🎉")` | `Text(lang.plants.completedLabel)` |
| `Text("📋 Attività")` | `Text(lang.plants.activitiesSectionTitle)` |
| `Text("Nessuna attività registrata per questa pianta.")` | `Text(lang.plants.noActivitiesPlant)` |
| `Text("In programma")` | `Text(lang.plants.scheduledSection)` |
| `Text("Completate / Passate")` | `Text(lang.plants.pastSection)` |
| `Text("🧺 Raccolti")` | `Text(lang.plants.harvestSectionTitle)` |
| `Text("Nessun raccolto registrato…")` | `Text(lang.plants.noHarvests)` |

Sostituzioni in `AttivitaRow`:
| Originale | Sostituzione |
|---|---|
| `Label("Ricorrente", systemImage: "repeat")` | `Label(lang.plants.recurringLabel, systemImage: "repeat")` |

Sostituzioni in `NuovoRaccoltoSheet`:
| Originale | Sostituzione |
|---|---|
| `DatePicker("Data", ...)` | `DatePicker(lang.plants.datePicker, ...)` |
| `Text("Quantità")` | `Text(lang.plants.quantityLabel)` |
| `TextField("Quantità", ...)` | `TextField(lang.plants.quantityPlaceholder, ...)` |
| `Picker("Unità", ...)` | `Picker(lang.plants.unitPicker, ...)` |
| `TextField("Note (facoltative)", ...)` | `TextField(lang.plants.optionalNotesPlaceholder, ...)` |
| footer `"Salvataggio non riuscito…"` | `Text(lang.plants.saveFailedMsg)` |
| `.navigationTitle("Nuovo raccolto")` | `.navigationTitle(lang.plants.newHarvestNavTitle)` |
| `Button("Annulla")` | `Button(lang.common.cancel)` |
| `Button("Salva")` | `Button(lang.common.save)` |

- [ ] **Step 3: Build + commit**

```bash
git add GardenCalendar/Views/Piante/PiantaListView.swift GardenCalendar/Views/Piante/PiantaDetailView.swift
git commit -m "feat(l10n): localize PiantaListView and PiantaDetailView"
```

---

## Task 8: Aggiornare `AggiungiPiantaView`, `NuovaAttivitaSheet`, `ModificaPiantaSheet`, `ModificaIntervalloSheet`

**Files:**
- Modify: `GardenCalendar/Views/Piante/AggiungiPiantaView.swift`
- Modify: `GardenCalendar/Views/Piante/NuovaAttivitaSheet.swift`
- Modify: `GardenCalendar/Views/Piante/ModificaPiantaSheet.swift`
- Modify: `GardenCalendar/Views/Piante/ModificaIntervalloSheet.swift`

- [ ] **Step 1: `AggiungiPiantaView.swift` — aggiungere environment e fix `alertIsSuccess`**

Aggiungi `@Environment(LanguageManager.self) private var lang` e un nuovo state:
```swift
@State private var alertIsSuccess = false
```

Nel metodo `savePianta()`, dove si setta `alertMessage`:
- Quando successo: aggiungi `alertIsSuccess = true` prima di `showAlert = true`
- Quando errore: aggiungi `alertIsSuccess = false` prima di `showAlert = true`
- Sostituisci anche i due `alertMessage = "…"` con `lang.plants.…`:
  - `alertMessage = lang.plants.cannotSaveNoOrto`
  - `alertMessage = String(format: lang.plants.addedSuccessFormat, nome)`
  - `alertMessage = lang.plants.enterPlantName`
  - Per errori: `alertMessage = error.localizedDescription` — invariato

Nell'`Alert`, sostituisci:
```swift
// prima:
Alert(
    title: Text(alertMessage.contains("successo") ? "Salvato" : "Errore"),
    message: Text(alertMessage),
    dismissButton: .default(Text("OK")) {
        if alertMessage.contains("successo") { dismiss() }
    }
)

// dopo:
Alert(
    title: Text(alertIsSuccess ? lang.plants.savedTitle : lang.common.error),
    message: Text(alertMessage),
    dismissButton: .default(Text(lang.common.ok)) {
        if alertIsSuccess { dismiss() }
    }
)
```

Altre sostituzioni:
| Originale | Sostituzione |
|---|---|
| `TextField("Cerca nel catalogo...", ...)` | `TextField(lang.plants.catalogSearchPlaceholder, ...)` |
| `ProgressView("Ricerca in corso...")` | `ProgressView(lang.plants.searchingLabel)` |
| `Text("Dal catalogo")` | `Text(lang.plants.catalogSection)` |
| `Text("Pianta personalizzata")` | `Text(lang.plants.customPlantSection)` |
| `TextField("Nome pianta", ...)` | `TextField(lang.plants.plantNamePlaceholder, ...)` |
| `Stepper("Ciclo crescita: \(customGrowthDays) giorni", ...)` | `Stepper(String(format: lang.plants.growthCycleFormat, customGrowthDays), ...)` |
| `DatePicker("Data semina", ...)` | `DatePicker(lang.plants.seedingDateLabel, ...)` |
| `Text("Attività importate dal catalogo")` | `Text(lang.plants.importedActivitiesSection)` |
| `.navigationTitle("Aggiungi pianta")` | `.navigationTitle(lang.plants.addPlantNavTitle)` |
| `Button("Annulla")` (toolbar leading) | `Button(lang.common.cancel)` |
| `Button("Salva", ...)` (toolbar trailing) | `Button(lang.common.save, ...)` |

- [ ] **Step 2: `NuovaAttivitaSheet.swift` — aggiungere environment**

Aggiungi `@Environment(LanguageManager.self) private var lang`.

Sostituzioni:
| Originale | Sostituzione |
|---|---|
| `Section("Dettagli attività")` | `Section(lang.plants.activityDetailsSection)` |
| `TextField("Es. irrigazione, concimazione…", ...)` | `TextField(lang.plants.activityNamePlaceholder, ...)` |
| `Picker("Tipo", ...)` | `Picker(lang.plants.activityTypePicker, ...)` |
| `Text("Ricorrente").tag(true)` | `Text(lang.plants.recurringType).tag(true)` |
| `Text("Una tantum").tag(false)` | `Text(lang.plants.oneOffType).tag(false)` |
| `Text("Intervallo")` (header Section) | `Text(lang.plants.intervalSection)` |
| `Stepper("Ogni \(valore) giorni", ...)` | `Stepper(String(format: lang.plants.everyNDaysFormat, valore), ...)` |
| `Stepper("Dopo \(valore) giorni dalla semina", ...)` | `Stepper(String(format: lang.plants.afterNDaysFormat, valore), ...)` |
| `.navigationTitle("Nuova attività")` | `.navigationTitle(lang.plants.newActivityNavTitle)` |
| `Button("Annulla")` | `Button(lang.common.cancel)` |
| `Button("Aggiungi")` | `Button(lang.plants.addButton)` |
| `.alert("Errore", ...)` | `.alert(lang.common.error, ...)` |
| `Button("OK", role: .cancel)` | `Button(lang.common.ok, role: .cancel)` |

- [ ] **Step 3: `ModificaPiantaSheet.swift` — aggiungere environment**

Aggiungi `@Environment(LanguageManager.self) private var lang`.

Sostituzioni:
| Originale | Sostituzione |
|---|---|
| `Text("Nessuna attività programmata.")` | `Text(lang.plants.noScheduledActivities)` |
| `Stepper("Ogni \(valori[att.nome] ?? 1) giorni", ...)` | `Stepper(String(format: lang.plants.everyNDaysFormat, valori[att.nome] ?? 1), ...)` |
| `Stepper("Dopo \(valori[att.nome] ?? 0) giorni dalla semina", ...)` | `Stepper(String(format: lang.plants.afterNDaysFormat, valori[att.nome] ?? 0), ...)` |
| `.navigationTitle("Modifica attività")` | `.navigationTitle(lang.plants.editActivitiesNavTitle)` |
| `Button("Annulla")` | `Button(lang.common.cancel)` |
| `Button("Salva")` | `Button(lang.common.save)` |
| `.alert("Errore", ...)` | `.alert(lang.common.error, ...)` |
| `Button("OK", role: .cancel)` | `Button(lang.common.ok, role: .cancel)` |

- [ ] **Step 4: `ModificaIntervalloSheet.swift` — aggiungere environment**

Aggiungi `@Environment(LanguageManager.self) private var lang`.

Sostituzioni:
| Originale | Sostituzione |
|---|---|
| `Stepper("Ogni \(valore) giorni", ...)` | `Stepper(String(format: lang.plants.everyNDaysFormat, valore), ...)` |
| `Stepper("Dopo \(valore) giorni dalla semina", ...)` | `Stepper(String(format: lang.plants.afterNDaysFormat, valore), ...)` |
| `Button("Ripristina default", role: .destructive)` | `Button(lang.plants.restoreDefault, role: .destructive)` |
| `.navigationTitle("Modifica intervallo")` | `.navigationTitle(lang.plants.editIntervalNavTitle)` |
| `Button("Annulla")` | `Button(lang.common.cancel)` |
| `Button("Salva")` | `Button(lang.common.save)` |
| `.alert("Errore", ...)` | `.alert(lang.common.error, ...)` |
| `Button("OK", role: .cancel)` | `Button(lang.common.ok, role: .cancel)` |

- [ ] **Step 5: Build + commit**

```bash
git add GardenCalendar/Views/Piante/AggiungiPiantaView.swift \
        GardenCalendar/Views/Piante/NuovaAttivitaSheet.swift \
        GardenCalendar/Views/Piante/ModificaPiantaSheet.swift \
        GardenCalendar/Views/Piante/ModificaIntervalloSheet.swift
git commit -m "feat(l10n): localize piante sheets (Aggiungi, NuovaAttivita, Modifica)"
```

---

## Task 9: Aggiornare `OrtoListView.swift` e `OrtoDetailView.swift`

**Files:**
- Modify: `GardenCalendar/Views/Orto/OrtoListView.swift`
- Modify: `GardenCalendar/Views/Orto/OrtoDetailView.swift`

- [ ] **Step 1: `OrtoListView.swift` — aggiungere environment**

Aggiungi `@Environment(LanguageManager.self) private var lang` alla struct `OrtoListView`.
Aggiungi anche a `OrtoCardRow` (struct nella stessa file): non ha stringhe hardcoded visibili, skip.

Sostituzioni in `OrtoListView`:
| Originale | Sostituzione |
|---|---|
| `.navigationTitle("I miei orti")` | `.navigationTitle(lang.garden.navTitle)` |
| `Label("Crea il tuo primo orto", ...)` (ContentUnavailableView) | `Label(lang.garden.emptyTitle, ...)` |
| `Text("Organizza le tue piante…")` | `Text(lang.garden.emptyDesc)` |
| `Label("Nuovo orto", ...)` (action button) | `Label(lang.garden.newGardenButton, ...)` |
| `Label("Elimina", systemImage: "trash")` (contextMenu) | `Label(lang.common.delete, systemImage: "trash")` |
| `.alert("Elimina orto", ...)` | `.alert(lang.garden.deleteTitle, ...)` |
| `Button("Elimina", role: .destructive)` | `Button(lang.garden.deleteButton, role: .destructive)` |
| `Button("Annulla", role: .cancel)` | `Button(lang.common.cancel, role: .cancel)` |
| message `"Eliminare l'orto \"\(orto.nome)\"?…"` | `Text(String(format: lang.garden.deleteConfirmMsgFormat, orto.nome))` |
| `.alert("Errore", ...)` | `.alert(lang.common.error, ...)` |
| `Button("OK", role: .cancel)` | `Button(lang.common.ok, role: .cancel)` |

Nel `newOrtoSheet`:
| Originale | Sostituzione |
|---|---|
| `Section("Dettagli orto")` | `Section(lang.garden.gardenDetailsSection)` |
| `TextField("Nome orto", ...)` | `TextField(lang.garden.gardenNamePlaceholder, ...)` |
| `Section("Posizione")` | `Section(lang.garden.locationSection)` |
| `TextField("Cerca città...", ...)` | `TextField(lang.garden.citySearchPlaceholder, ...)` |
| `Label(locationHelper.isLocating ? "Rilevamento GPS..." : "Usa posizione attuale", ...)` | `Label(locationHelper.isLocating ? lang.garden.detectingGPS : lang.garden.useCurrentLocation, ...)` |
| `Text("Salva")` (bottone sheet) | `Text(lang.common.save)` |
| `.navigationTitle("Nuovo orto")` | `.navigationTitle(lang.garden.newOrtoNavTitle)` |
| `Button("Annulla")` (toolbar) | `Button(lang.common.cancel)` |

- [ ] **Step 2: `OrtoDetailView.swift` — aggiungere environment**

Aggiungi `@Environment(LanguageManager.self) private var lang` a `OrtoDetailView`.
Aggiungi anche a `PiantaRowView` (struct nella stessa file): ha `Text("\(pianta.growthDays) giorni")`.

Sostituzioni in `OrtoDetailView`:
| Originale | Sostituzione |
|---|---|
| `Button("Modifica")` (toolbar) | `Button(lang.garden.editButton)` |
| `Text("Piante")` (section header) | `Text(lang.garden.plantsSection)` |
| `Text("Aggiungi la tua prima pianta")` (emptyPiante) | `Text(lang.garden.emptyFirstPlant)` |
| `Label("Aggiungi pianta", ...)` (button) | `Label(lang.garden.addPlantButton, ...)` |

Nel `editOrtoSheet`:
| Originale | Sostituzione |
|---|---|
| `Section("Dettagli orto")` | `Section(lang.garden.gardenDetailsSection)` |
| `TextField("Nome orto", ...)` | `TextField(lang.garden.gardenNamePlaceholder, ...)` |
| `Section("Posizione")` | `Section(lang.garden.locationSection)` |
| `TextField("Cerca città...", ...)` | `TextField(lang.garden.citySearchPlaceholder, ...)` |
| `Label(... ? "Rilevamento GPS..." : "Usa posizione attuale", ...)` | `Label(locationHelper.isLocating ? lang.garden.detectingGPS : lang.garden.useCurrentLocation, ...)` |
| `Text("Salva")` (bottone) | `Text(lang.common.save)` |
| `.navigationTitle("Modifica orto")` | `.navigationTitle(lang.garden.editNavTitle)` |
| `Button("Annulla")` | `Button(lang.common.cancel)` |
| `Button("Elimina orto")` | `Button(lang.garden.deleteOrtoButton)` — nel `Button(role: .destructive)` dentro il form |
| `.alert("Elimina orto", ...)` | `.alert(lang.garden.deleteTitle, ...)` |
| `Button("Elimina", role: .destructive)` | `Button(lang.garden.deleteButton, role: .destructive)` |
| `Button("Annulla", role: .cancel)` | `Button(lang.common.cancel, role: .cancel)` |
| message `"Eliminare l'orto \"\(orto.nome)\"?…"` | `Text(String(format: lang.garden.deleteConfirmMsgFormat, orto.nome))` |
| `.alert("Errore", ...)` | `.alert(lang.common.error, ...)` |
| `Button("OK", role: .cancel)` | `Button(lang.common.ok, role: .cancel)` |

In `PiantaRowView`:
Aggiungi `@Environment(LanguageManager.self) private var lang`.

| Originale | Sostituzione |
|---|---|
| `Text("\(pianta.growthDays) giorni")` | `Text(String(format: lang.plants.totalDaysFormat, pianta.growthDays))` |

- [ ] **Step 3: Build + commit**

```bash
git add GardenCalendar/Views/Orto/OrtoListView.swift GardenCalendar/Views/Orto/OrtoDetailView.swift
git commit -m "feat(l10n): localize OrtoListView and OrtoDetailView"
```

---

## Task 10: Aggiornare `QuickJournalView.swift` e `NotificationManager.swift`

**Files:**
- Modify: `GardenCalendar/Views/Journal/QuickJournalView.swift`
- Modify: `GardenCalendar/Services/NotificationManager.swift`

- [ ] **Step 1: `QuickJournalView.swift` — aggiungere environment e fix `alertIsSuccess`**

Aggiungi `@Environment(LanguageManager.self) private var lang` e nuovo state:
```swift
@State private var alertIsSuccess = false
```

Nel metodo `saveEntry()`:
- Quando successo: `alertIsSuccess = true` e `alertMessage = lang.journal.savedSuccess`
- Quando errore: `alertIsSuccess = false`, `alertMessage = error.localizedDescription` (invariato)

Nell'`Alert`, sostituisci:
```swift
// prima:
Alert(
    title: Text(alertMessage.contains("salvato") ? "Salvato" : "Errore"),
    message: Text(alertMessage),
    dismissButton: .default(Text("OK")) {
        if alertMessage.contains("salvato") { dismiss() }
    }
)

// dopo:
Alert(
    title: Text(alertIsSuccess ? lang.plants.savedTitle : lang.common.error),
    message: Text(alertMessage),
    dismissButton: .default(Text(lang.common.ok)) {
        if alertIsSuccess { dismiss() }
    }
)
```

Nella funzione `stepTitle(_ number: Int)`:
```swift
// prima:
case 1: return "Pianta"
case 2: return "Azione"
case 3: return "Dettagli"

// dopo:
case 1: return LanguageManager.shared.journal.stepPlant
case 2: return LanguageManager.shared.journal.stepAction
case 3: return LanguageManager.shared.journal.stepDetails
```

Altre sostituzioni:
| Originale | Sostituzione |
|---|---|
| `.navigationTitle("Nuovo Journal Entry")` | `.navigationTitle(lang.journal.navTitle)` |
| `Button("Annulla")` | `Button(lang.common.cancel)` |
| `Button("Avanti")` | `Button(lang.journal.nextButton)` |
| `ContentUnavailableView("Nessuna pianta", ...)` | `ContentUnavailableView(lang.journal.noPlantsTitle, ...)` |
| description `Text("Aggiungi prima una pianta…")` | `Text(lang.journal.noPlantsDesc)` |
| `Section("Pianta")` (step 3) | `Section(lang.journal.sectionPlant)` |
| `Section("Azione")` | `Section(lang.journal.sectionAction)` |
| `Section("Data")` | `Section(lang.journal.sectionDate)` |
| `DatePicker("Data evento", ...)` | `DatePicker(lang.journal.dateEventLabel, ...)` |
| `Section("Nota (opzionale)")` | `Section(lang.journal.sectionNote)` |
| `Text("Salva Journal Entry")` | `Text(lang.journal.saveEntryButton)` |

- [ ] **Step 2: `NotificationManager.swift` — usare `LanguageManager.shared`**

Nel metodo `reschedule(activities:)`, trovare (circa riga 68-73):
```swift
let content = UNMutableNotificationContent()
content.title = "🌱 Attività di oggi nell'orto"
let names = dayActivities.map { $0.nome.capitalized }
let unique = Array(NSOrderedSet(array: names)) as? [String] ?? names
let summary = unique.prefix(3).joined(separator: ", ")
let extra = dayActivities.count > 3 ? " e altre" : ""
content.body = "\(dayActivities.count) attività: \(summary)\(extra)"
```

Sostituire con:
```swift
let content = UNMutableNotificationContent()
let lang = LanguageManager.shared
content.title = lang.notifications.dailyTitle
let names = dayActivities.map { $0.nome.capitalized }
let unique = Array(NSOrderedSet(array: names)) as? [String] ?? names
let summary = unique.prefix(3).joined(separator: ", ")
let extra = dayActivities.count > 3 ? lang.notifications.andMore : ""
content.body = String(format: lang.notifications.activitiesCountFormat,
                      dayActivities.count, summary, extra)
```

- [ ] **Step 3: Build + commit**

```bash
git add GardenCalendar/Views/Journal/QuickJournalView.swift GardenCalendar/Services/NotificationManager.swift
git commit -m "feat(l10n): localize QuickJournalView and NotificationManager"
```

---

## Task 11: Aggiornare i `#Preview` con `LanguageManager`

**Files:** tutti i file modificati nei task 3-10 che hanno `#Preview`

- [ ] **Step 1: Aggiungere `.environment(LanguageManager.shared)` a ogni `#Preview`**

In ciascun file con `#Preview { ... }`, aggiungere `.environment(LanguageManager.shared)` nella catena degli environment. Esempio:

```swift
// prima:
#Preview {
    LoginView()
        .environment(AuthManager.shared)
}

// dopo:
#Preview {
    LoginView()
        .environment(AuthManager.shared)
        .environment(LanguageManager.shared)
}
```

File con preview da aggiornare:
- `LoginView.swift`
- `SignUpView.swift`
- `SettingsView.swift`
- `PiantaListView.swift`
- `PiantaDetailView.swift`
- `AggiungiPiantaView.swift`
- `OrtoListView.swift`
- `OrtoDetailView.swift`
- `QuickJournalView.swift`

- [ ] **Step 2: Build finale — deve compilare senza warning**

`Cmd+B` in Xcode. Nessun errore atteso.

- [ ] **Step 3: Commit finale**

```bash
git add -u
git commit -m "feat(l10n): update all #Preview environments for LanguageManager"
```

---

## Verifica manuale

Dopo il Task 11, testare manualmente:

1. Aprire Settings → sezione Lingua → selezionare "English"
2. Verificare che tutte le view passino istantaneamente all'inglese
3. Chiudere e riaprire l'app → deve ricordare "English"
4. Tornare a "Italiano" → tutte le view tornano all'italiano
5. Verificare che il delete account richieda "DELETE" in inglese e "ELIMINA" in italiano
