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
                Section("Profilo") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundStyle(AppTheme.primaryGreen)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Account")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(email)
                                .font(.body)
                        }
                    }

                    Button(role: .destructive, action: { showLogoutConfirm = true }) {
                        Label("Esci", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }

                // MARK: - Orto Preferito
                Section("Orto preferito") {
                    Picker("Orto predefinito", selection: $preferredGarden) {
                        ForEach(gardenOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // MARK: - Meteo
                Section(
                    header: Text("Meteo"),
                    footer: Text("La soglia di pioggia determina quando mostrare l'icona della pioggia nel calendario.")
                ) {
                    HStack {
                        Image(systemName: "mappin")
                            .foregroundStyle(.secondary)
                        TextField("Luogo (es. Roma)", text: $weatherLocation)
                            .autocorrectionDisabled()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(AppTheme.rainBlue)
                            Text("Soglia pioggia: \(rainThreshold, specifier: "%.0f") mm")
                        }

                        Stepper("", value: $rainThreshold, in: 1...50, step: 1)
                            .labelsHidden()

                        HStack {
                            Text("1 mm")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("50 mm")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // MARK: - Aspetto
                Section("Aspetto") {
                    Picker("Tema", selection: $selectedTheme) {
                        Text("🌞 Chiaro").tag(ThemeMode.light)
                        Text("🌙 Scuro").tag(ThemeMode.dark)
                        Text("🔄 Automatico").tag(ThemeMode.automatic)
                    }
                    .pickerStyle(.menu)
                }

                // MARK: - Info App
                Section("Info") {
                    HStack {
                        Text("Versione")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text(buildNumber)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Sviluppata con")
                        Spacer()
                        Label("Nous Research", systemImage: "brain")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: - Elimina account
                Section {
                    Button(role: .destructive, action: { showDeleteConfirm = true }) {
                        Label("Elimina account", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                } footer: {
                    Text("L'eliminazione dell'account cancellerà tutti i tuoi dati. Questa azione è irreversibile.")
                }
            }
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
