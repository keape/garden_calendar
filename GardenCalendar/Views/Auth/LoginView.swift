import SwiftUI

/// Schermata di login con email/password, link registrazione, reset password e Apple Sign-In.
struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showResetPassword = false
    @State private var resetEmail = ""
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var resetSent = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Sfondo con gradiente verde tenue
                LinearGradient(
                    colors: [
                        AppTheme.primaryGreen.opacity(0.08),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 60)

                        // Icona e titolo
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(AppTheme.primaryGreen)

                        Text("Garden Calendar")
                            .font(.largeTitle.bold())
                            .foregroundStyle(AppTheme.primaryGreen)

                        Text("Il tuo diario di giardinaggio intelligente")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer().frame(height: 20)

                        // Card login
                        VStack(spacing: 16) {
                            Text("Accedi")
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: 12) {
                                TextField("Email", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(AppTheme.cardSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                SecureField("Password", text: $password)
                                    .textContentType(.password)
                                    .padding()
                                    .background(AppTheme.cardSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            // Bottone Login
                            Button(action: performLogin) {
                                Group {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Accedi")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.primaryGreen)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(authManager.isLoading || email.trimmingCharacters(in: .whitespaces).isEmpty || password.isEmpty)

                            // Link registrati
                            Button(action: { showSignUp = true }) {
                                Text("Non hai un account? **Registrati**")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.primaryGreen)
                            }

                            // Link password dimenticata
                            Button(action: { showResetPassword = true }) {
                                Text("Password dimenticata?")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(24)
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                        .padding(.horizontal, 24)

                        // Separatore
                        HStack {
                            Rectangle().frame(height: 1).foregroundStyle(.secondary.opacity(0.3))
                            Text("oppure").font(.caption).foregroundStyle(.secondary)
                            Rectangle().frame(height: 1).foregroundStyle(.secondary.opacity(0.3))
                        }
                        .padding(.horizontal, 40)

                        // Apple Sign-In button
                        Button(action: performAppleSignIn) {
                            Label("Accedi con Apple", systemImage: "applelogo")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.black)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 24)

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .alert("Password dimenticata", isPresented: $showResetPassword) {
                TextField("Inserisci la tua email", text: $resetEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                Button("Invia") {
                    Task { try? await authManager.resetPassword(email: resetEmail) }
                    resetSent = true
                }
                Button("Annulla", role: .cancel) {}
            } message: {
                Text("Riceverai un'email per reimpostare la password.")
            }
            .alert("Errore", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Si è verificato un errore sconosciuto.")
            }
            .alert("Email inviata", isPresented: $resetSent) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Controlla la tua casella di posta per reimpostare la password.")
            }
        }
    }

    private func performLogin() {
        Task {
            do {
                try await authManager.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func performAppleSignIn() {
        // Apple Sign-In would be integrated via AuthenticationServices
        // For now, this is a placeholder
        errorMessage = "Apple Sign-In sarà disponibile a breve."
        showError = true
    }
}

#Preview {
    LoginView()
        .environment(AuthManager.shared)
}
