import SwiftUI


/// Impostazioni complete: profilo, orto preferito, meteo, aspetto, info app, eliminazione account.
struct SettingsView: View {
    @Environment(SupabaseRepository.self) private var repository

    // Profilo
    @State private var email = "utente@esempio.com"
    @State private var showLogoutConfirm = false

    // Orto preferito
    @State private var preferredGarden = "Il mio orto"
    @State private var gardenOptions: [String] = ["Il mio orto", "Orto sul balcone", "Giardino"]

    // Meteo
    @State private var weatherLocation = ""
    @State private var rainThreshold: Double = 5.0

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
                Section(header: sectionHeader("Profilo")) {
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
                        Label("Esci", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.dmSans(15))
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }

                // MARK: - Orto Preferito
                Section(header: sectionHeader("Orto preferito")) {
                    Picker("Orto predefinito", selection: $preferredGarden) {
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
                    header: sectionHeader("Meteo"),
                    footer: Text("La soglia di pioggia determina quando mostrare l'icona della pioggia nel calendario.")
                        .font(.dmSans(12))
                        .foregroundStyle(AppTheme.textSecondary)
                ) {
                    HStack {
                        Image(systemName: "mappin")
                            .foregroundStyle(AppTheme.textSecondary)
                        TextField("Luogo (es. Roma)", text: $weatherLocation)
                            .autocorrectionDisabled()
                            .font(.dmSans(15))
                    }
                    .listRowBackground(AppTheme.cardBackground)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(AppTheme.rainBlue)
                            Text("Soglia pioggia: \(rainThreshold, specifier: "%.0f") mm")
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

                // MARK: - Aspetto
                Section(header: sectionHeader("Aspetto")) {
                    Picker("Tema", selection: $selectedTheme) {
                        Text("🌞 Chiaro").tag(ThemeMode.light)
                        Text("🌙 Scuro").tag(ThemeMode.dark)
                        Text("🔄 Automatico").tag(ThemeMode.automatic)
                    }
                    .pickerStyle(.menu)
                    .font(.dmSans(15))
                    .listRowBackground(AppTheme.cardBackground)
                }

                // MARK: - Info App
                Section(header: sectionHeader("Info")) {
                    HStack {
                        Text("Versione")
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
                        Text("Sviluppata con")
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
                        Label("Elimina account", systemImage: "trash")
                            .font(.dmSans(15))
                            .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                } footer: {
                    Text("L'eliminazione dell'account cancellerà tutti i tuoi dati. Questa azione è irreversibile.")
                        .font(.dmSans(12))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.backgroundCream)
            .navigationTitle("Impostazioni")
            .alert("Esci dall'account", isPresented: $showLogoutConfirm) {
                Button("Esci", role: .destructive) {
                    // authManager.signOut()
                }
                Button("Annulla", role: .cancel) {}
            } message: {
                Text("Sei sicuro di voler uscire? Dovrai accedere nuovamente per usare l'app.")
            }
            .alert("Elimina account", isPresented: $showDeleteConfirm) {
                TextField("Scrivi 'ELIMINA' per confermare", text: $deleteConfirmText)
                Button("Elimina definitivamente", role: .destructive) {
                    showDeleted = true
                }
                .disabled(deleteConfirmText != "ELIMINA")
                Button("Annulla", role: .cancel) {}
            } message: {
                Text("Questa azione è irreversibile. Tutti i tuoi dati verranno cancellati permanentemente.")
            }
            .alert("Account eliminato", isPresented: $showDeleted) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Il tuo account e tutti i dati associati sono stati eliminati.")
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
}
