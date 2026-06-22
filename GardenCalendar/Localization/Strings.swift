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
        let cancel, save, confirm, delete, edit, add, error, ok, next, retry, loading: String
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
        let resetButton: String
        let confirmPasswordPlaceholder: String
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
        let rainThresholdLabel: String
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
        let rainToastPlural: String
        let noActivitiesAgenda: String
        let legendSeedTransplant: String
        let legendHarvest: String
        let legendWatering: String
        let legendTreatment: String
        let legendPruning: String
        let legendReminder: String
        let todayLabel: String
        let tomorrowLabel: String
        let loadErrorMsg: String
        let seminaSectionTitleFormat: String
        let seminaIndoorBadge: String
    }

    struct DayDetailStrings {
        let activitiesTitle: String
        let noActivitiesDay: String
        let addActivity: String
        let rainMmFormat: String
        let frostFormat: String
        let swipeForward: String
        let swipeBack: String
        let rescheduleTitle: String
        let rescheduleSection: String
        let newDateLabel: String
        let rescheduleConfirm: String
        let dateLocale: String
    }

    struct PlantsStrings {
        let navTitle: String
        let searchPlaceholder: String
        let emptyTitle: String
        let emptyDesc: String
        let addPlantButton: String
        let totalDaysFormat: String
        let activitiesCountFormat: String
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
        let growthCycleFormat: String
        let seedingDateLabel: String
        let importedActivitiesSection: String
        let searchingLabel: String
        let addPlantNavTitle: String
        let cannotSaveNoOrto: String
        let addedSuccessFormat: String
        let enterPlantName: String
        let savedTitle: String
        let newActivityNavTitle: String
        let activityDetailsSection: String
        let activityNamePlaceholder: String
        let activityTypePicker: String
        let recurringType: String
        let oneOffType: String
        let intervalSection: String
        let everyNDaysFormat: String
        let afterNDaysFormat: String
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
        let plantDetailTitle: String
        let seedingSection: String
        let careSection: String
        let detailActivitiesSection: String
        let companionsSection: String
        let addToGardenButton: String
        let wateringLabel: String
        let exposureLabel: String
        let harvestMonthsLabel: String
        let everyNDaysShortFormat: String
        let afterNDaysShortFormat: String
        let addPhotoButton: String
        let changePhotoButton: String
        let removePhotoButton: String
        let onlineCatalogSection: String
        let partialDataBadge: String
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
        let deleteConfirmMsgFormat: String
        let deleteTitle: String
        let deleteButton: String
        let editNavTitle: String
        let deleteOrtoButton: String
        let plantsSection: String
        let emptyFirstPlant: String
        let addPlantButton: String
        let editButton: String
        let newOrtoNavTitle: String
        let plantsCountFormat: String
        let indoorToggle: String
        let indoorFooter: String
        let photoSection: String
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
        let activitiesCountFormat: String
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
            error: "Errore", ok: "OK", next: "Avanti", retry: "Riprova",
            loading: "Caricamento…"
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
            registrationSuccessMessage: "Controlla la tua email per confermare l'account.",
            resetButton: "Invia",
            confirmPasswordPlaceholder: "Conferma password"
        ),
        settings: SettingsStrings(
            navTitle: "Impostazioni",
            profileSection: "Profilo",
            logoutButton: "Esci",
            logoutConfirmTitle: "Esci dall'account",
            logoutConfirmMsg: "Sei sicuro di voler uscire? Dovrai accedere nuovamente per usare l'app.",
            preferredGardenSection: "Giardino preferito",
            defaultGardenPicker: "Giardino predefinito",
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
            filterAllGardens: "Tutti i giardini",
            filterAllTypes: "Tutte le tipologie",
            filterAllPlants: "Tutte le piante",
            filterGardenDefault: "Giardino",
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
            todayLabel: "Oggi",
            tomorrowLabel: "Domani",
            loadErrorMsg: "Impossibile caricare le attività. Controlla la connessione.",
            seminaSectionTitleFormat: "Da seminare a %@",
            seminaIndoorBadge: "interno"
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
            saveFailedMsg: "Salvataggio non riuscito. Controlla la connessione e riprova.",
            plantDetailTitle: "Scheda pianta",
            seedingSection: "Quando seminare",
            careSection: "Cure",
            detailActivitiesSection: "Attività generate",
            companionsSection: "Piante compagne",
            addToGardenButton: "Aggiungi all'orto",
            wateringLabel: "Annaffiatura",
            exposureLabel: "Esposizione",
            harvestMonthsLabel: "Mesi raccolta",
            everyNDaysShortFormat: "ogni %dgg",
            afterNDaysShortFormat: "dopo %dgg",
            addPhotoButton: "Aggiungi foto",
            changePhotoButton: "Cambia foto",
            removePhotoButton: "Rimuovi foto",
            onlineCatalogSection: "Cerca online",
            partialDataBadge: "Dati parziali"
        ),
        garden: GardenStrings(
            navTitle: "I miei giardini",
            emptyTitle: "Crea il tuo primo giardino",
            emptyDesc: "Organizza le tue piante in giardini per tenerle sotto controllo.",
            newGardenButton: "Nuovo giardino",
            gardenDetailsSection: "Dettagli giardino",
            gardenNamePlaceholder: "Nome giardino",
            locationSection: "Posizione",
            citySearchPlaceholder: "Cerca città...",
            useCurrentLocation: "Usa posizione attuale",
            detectingGPS: "Rilevamento GPS...",
            deleteConfirmMsgFormat: "Eliminare il giardino \"%@\"? Le piante collegate non verranno eliminate.",
            deleteTitle: "Elimina giardino",
            deleteButton: "Elimina",
            editNavTitle: "Modifica giardino",
            deleteOrtoButton: "Elimina giardino",
            plantsSection: "Piante",
            emptyFirstPlant: "Aggiungi la tua prima pianta",
            addPlantButton: "Aggiungi pianta",
            editButton: "Modifica",
            newOrtoNavTitle: "Nuovo giardino",
            plantsCountFormat: "%d piante",
            indoorToggle: "Giardino interno",
            indoorFooter: "Per i giardini interni la riprogrammazione automatica dell'irrigazione in base alla pioggia è disattivata.",
            photoSection: "Foto del giardino"
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
            dailyTitle: "🌱 Attività di oggi nel giardino",
            andMore: " e altre",
            activitiesCountFormat: "%d attività: %@%@"
        ),
        tabs: TabsStrings(
            calendar: "Calendario",
            gardens: "Giardini",
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
            error: "Error", ok: "OK", next: "Next", retry: "Retry",
            loading: "Loading…"
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
            registrationSuccessMessage: "Check your email to confirm your account.",
            resetButton: "Send",
            confirmPasswordPlaceholder: "Confirm password"
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
            todayLabel: "Today",
            tomorrowLabel: "Tomorrow",
            loadErrorMsg: "Unable to load activities. Check your connection.",
            seminaSectionTitleFormat: "Sow in %@",
            seminaIndoorBadge: "indoor"
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
            saveFailedMsg: "Save failed. Check your connection and try again.",
            plantDetailTitle: "Plant Info",
            seedingSection: "Sowing Calendar",
            careSection: "Care",
            detailActivitiesSection: "Suggested Activities",
            companionsSection: "Companion Plants",
            addToGardenButton: "Add to Garden",
            wateringLabel: "Watering",
            exposureLabel: "Exposure",
            harvestMonthsLabel: "Harvest months",
            everyNDaysShortFormat: "every %dd",
            afterNDaysShortFormat: "after %dd",
            addPhotoButton: "Add photo",
            changePhotoButton: "Change photo",
            removePhotoButton: "Remove photo",
            onlineCatalogSection: "Search online",
            partialDataBadge: "Partial data"
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
            newOrtoNavTitle: "New garden",
            plantsCountFormat: "%d plants",
            indoorToggle: "Indoor garden",
            indoorFooter: "For indoor gardens, automatic rain-based irrigation rescheduling is disabled.",
            photoSection: "Garden photo"
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

    var common:        Strings.Common               { strings.common }
    var auth:          Strings.Auth                 { strings.auth }
    var settings:      Strings.SettingsStrings      { strings.settings }
    var calendar:      Strings.CalendarStrings      { strings.calendar }
    var dayDetail:     Strings.DayDetailStrings     { strings.dayDetail }
    var plants:        Strings.PlantsStrings        { strings.plants }
    var garden:        Strings.GardenStrings        { strings.garden }
    var journal:       Strings.JournalStrings       { strings.journal }
    var notifications: Strings.NotificationsStrings { strings.notifications }
    var tabs:          Strings.TabsStrings          { strings.tabs }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "it"
        let lang = AppLanguage(rawValue: saved) ?? .it
        self.language = lang
        self.strings = lang.strings
    }
}
