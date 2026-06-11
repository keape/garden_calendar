import SwiftUI


/// Impostazioni complete: profilo, orto preferito, meteo, aspetto, info app, eliminazione account.
struct SettingsView: View {
    @Environment(SupabaseRepository.self) private var repository
    @Environment(AuthManager.self) private var authManager
    @Environment(LanguageManager.self) private var lang

    // Profilo
    @State private var email = ""
    @State private var showLogoutConfirm = false

    // Orto preferito
    @State private var preferredGarden = "Il mio orto"
    @State private var gardenOptions: [String] = ["Il mio orto", "Orto sul balcone", "Giardino"]

    // Meteo
    @State private var weatherLocation = ""
    @State private var rainThreshold: Double = 5.0

    // Notifiche
    @State private var notificationsEnabled = NotificationManager.shared.isEnabled
    @State private var notificationHour = NotificationManager.shared.notificationHour
    @State private var showNotificationsDenied = false

    // Aspetto
    @State private var selectedTheme: ThemeMode = .automatic

    // App Info
    @State private var appVersion = "1.0.0"
    @State private var buildNumber = "1"

    // Delete account
    @State private var showDeleteConfirm = false
    @State private var deleteConfirmText = ""
    @State private var showDeleted = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Profilo
                Section(header: sectionHeader(lang.settings.profileSection)) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundStyle(AppTheme.primaryGreen)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Account")
                                .font(.dmSans(13))
                                .foregroundStyle(AppTheme.textSecondary)
                            Text(email)
                                .font(.dmSans(15))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                    }
                    .listRowBackground(AppTheme.cardBackground)

                    Button(role: .destructive, action: { showLogoutConfirm = true }) {
                        Label(lang.settings.logoutButton, systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.dmSans(15))
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }

                // MARK: - Orto Preferito
                Section(header: sectionHeader(lang.settings.preferredGardenSection)) {
                    Picker(lang.settings.defaultGardenPicker, selection: $preferredGarden) {
                        ForEach(gardenOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.dmSans(15))
                    .listRowBackground(AppTheme.cardBackground)
                }

                // MARK: - Meteo
                Section(
                    header: sectionHeader(lang.settings.weatherSection),
                    footer: Text(lang.settings.rainFooter)
                        .font(.dmSans(12))
                        .foregroundStyle(AppTheme.textSecondary)
                ) {
                    HStack {
                        Image(systemName: "mappin")
                            .foregroundStyle(AppTheme.textSecondary)
                        TextField(lang.settings.weatherPlaceholder, text: $weatherLocation)
                            .autocorrectionDisabled()
                            .font(.dmSans(15))
                    }
                    .listRowBackground(AppTheme.cardBackground)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(AppTheme.rainBlue)
                            Text(String(format: lang.settings.rainThresholdLabel, rainThreshold))
                                .font(.dmSans(15))
                        }

                        Stepper("", value: $rainThreshold, in: 1...50, step: 1)
                            .labelsHidden()

                        HStack {
                            Text("1 mm")
                                .font(.dmSans(11))
                                .foregroundStyle(AppTheme.textSecondary)
                            Spacer()
                            Text("50 mm")
                                .font(.dmSans(11))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }

                // MARK: - Notifiche
                Section(
                    header: sectionHeader(lang.settings.notificationsSection),
                    footer: Text(lang.settings.notifFooter)
                        .font(.dmSans(12))
                        .foregroundStyle(AppTheme.textSecondary)
                ) {
                    Toggle(isOn: $notificationsEnabled) {
                        Label(lang.settings.dailyReminderToggle, systemImage: "bell.badge")
                            .font(.dmSans(15))
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    .onChange(of: notificationsEnabled) { _, newValue in
                        NotificationManager.shared.isEnabled = newValue
                        Task {
                            if newValue {
                                let granted = await NotificationManager.shared.requestAuthorization()
                                if !granted {
                                    notificationsEnabled = false
                                    NotificationManager.shared.isEnabled = false
                                    showNotificationsDenied = true
                                }
                            } else {
                                NotificationManager.shared.cancelAll()
                            }
                        }
                    }

                    if notificationsEnabled {
                        Picker(lang.settings.reminderHourPicker, selection: $notificationHour) {
                            ForEach(5..<13, id: \.self) { h in
                                Text(String(format: "%02d:00", h)).tag(h)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(.dmSans(15))
                        .listRowBackground(AppTheme.cardBackground)
                        .onChange(of: notificationHour) { _, newValue in
                            NotificationManager.shared.notificationHour = newValue
                        }
                    }
                }

                // MARK: - Lingua
                Section(header: sectionHeader(lang.settings.languageSection)) {
                    Picker(lang.settings.languagePickerLabel, selection: Binding(
                        get: { LanguageManager.shared.language },
                        set: { LanguageManager.shared.language = $0 }
                    )) {
                        ForEach(AppLanguage.allCases, id: \.self) { l in
                            Text(l.displayName).tag(l)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.dmSans(15))
                    .listRowBackground(AppTheme.cardBackground)
                }

                // MARK: - Aspetto
                Section(header: sectionHeader(lang.settings.appearanceSection)) {
                    Picker(lang.settings.themePicker, selection: $selectedTheme) {
                        Text(lang.settings.themeLight).tag(ThemeMode.light)
                        Text(lang.settings.themeDark).tag(ThemeMode.dark)
                        Text(lang.settings.themeAuto).tag(ThemeMode.automatic)
                    }
                    .pickerStyle(.menu)
                    .font(.dmSans(15))
                    .listRowBackground(AppTheme.cardBackground)
                }

                // MARK: - Info App
                Section(header: sectionHeader(lang.settings.infoSection)) {
                    HStack {
                        Text(lang.settings.versionLabel)
                            .font(.dmSans(15))
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Text(appVersion)
                            .font(.dmSans(15))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .listRowBackground(AppTheme.cardBackground)

                    HStack {
                        Text("Build")
                            .font(.dmSans(15))
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Text(buildNumber)
                            .font(.dmSans(15))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .listRowBackground(AppTheme.cardBackground)

                    HStack {
                        Text(lang.settings.builtWithLabel)
                            .font(.dmSans(15))
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Label("Nous Research", systemImage: "brain")
                            .font(.dmSans(12))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }

                // MARK: - Elimina account
                Section {
                    Button(role: .destructive, action: { showDeleteConfirm = true }) {
                        Label(lang.settings.deleteAccountButton, systemImage: "trash")
                            .font(.dmSans(15))
                            .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                } footer: {
                    Text(lang.settings.deleteAccountFooter)
                        .font(.dmSans(12))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.backgroundCream)
            .navigationTitle(lang.settings.navTitle)
            .alert(lang.settings.logoutConfirmTitle, isPresented: $showLogoutConfirm) {
                Button(lang.settings.logoutButton, role: .destructive) {
                    Task { await authManager.signOut() }
                }
                Button(lang.common.cancel, role: .cancel) {}
            } message: {
                Text(lang.settings.logoutConfirmMsg)
            }
            .alert(lang.settings.deleteConfirmTitle, isPresented: $showDeleteConfirm) {
                TextField(lang.settings.deleteConfirmPlaceholder, text: $deleteConfirmText)
                Button(lang.settings.deleteConfirmButton, role: .destructive) {
                    showDeleted = true
                }
                .disabled(deleteConfirmText != lang.settings.deleteConfirmKeyword)
                Button(lang.common.cancel, role: .cancel) {}
            } message: {
                Text(lang.settings.deleteConfirmMsg)
            }
            .alert(lang.settings.notifDeniedTitle, isPresented: $showNotificationsDenied) {
                Button(lang.common.ok, role: .cancel) {}
            } message: {
                Text(lang.settings.notifDeniedMsg)
            }
            .alert(lang.settings.deletedTitle, isPresented: $showDeleted) {
                Button(lang.common.ok, role: .cancel) {}
            } message: {
                Text(lang.settings.deletedMsg)
            }
            .onAppear {
                loadSettings()
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.dmSans(12, weight: .semibold))
            .foregroundStyle(AppTheme.textSecondary)
            .textCase(nil)
    }

    private func loadSettings() {
        email = authManager.user?.email ?? ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildNumber = build
        }
    }
}

// MARK: - Theme Mode

enum ThemeMode: String, CaseIterable {
    case light = "chiaro"
    case dark = "scuro"
    case automatic = "automatico"

    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .automatic: return nil
        }
    }
}

#Preview {
    SettingsView()
        .environment(SupabaseRepository.shared)
        .environment(AuthManager.shared)
        .environment(LanguageManager.shared)
}
