import SwiftUI
import AuthenticationServices

/// Schermata di login con email/password, link registrazione, reset password e Apple Sign-In.
struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(LanguageManager.self) private var lang
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
                AppTheme.backgroundCream
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 60)

                        // Icona e titolo
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(AppTheme.primaryGreen)

                        Text("Garden Calendar")
                            .font(.lora(28))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text(lang.auth.appSubtitle)
                            .font(.dmSans(14))
                            .foregroundStyle(AppTheme.textSecondary)

                        Spacer().frame(height: 20)

                        // Card login
                        VStack(spacing: 16) {
                            Text(lang.auth.loginCardTitle)
                                .font(.dmSans(18, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: 12) {
                                TextField("Email", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(AppTheme.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.cardSecondaryWarm, lineWidth: 1))

                                SecureField("Password", text: $password)
                                    .textContentType(.password)
                                    .padding()
                                    .background(AppTheme.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.cardSecondaryWarm, lineWidth: 1))
                            }

                            // Bottone Login
                            Button(action: performLogin) {
                                Group {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text(lang.auth.loginButton)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.primaryGreen)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                            }
                            .disabled(authManager.isLoading || email.trimmingCharacters(in: .whitespaces).isEmpty || password.isEmpty)

                            // Link registrati
                            Button(action: { showSignUp = true }) {
                                Text(.init(lang.auth.signUpLink))
                                    .font(.dmSans(14))
                                    .foregroundStyle(AppTheme.primaryGreen)
                            }

                            // Link password dimenticata
                            Button(action: { showResetPassword = true }) {
                                Text(lang.auth.forgotPassword)
                                    .font(.dmSans(14))
                                    .foregroundStyle(AppTheme.textSecondary)
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
                            Text(lang.auth.orSeparator).font(.caption).foregroundStyle(.secondary)
                            Rectangle().frame(height: 1).foregroundStyle(.secondary.opacity(0.3))
                        }
                        .padding(.horizontal, 40)

                        // Apple Sign-In button
                        Button(action: performAppleSignIn) {
                            Label(lang.auth.appleSignIn, systemImage: "applelogo")
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
            .alert(lang.auth.resetTitle, isPresented: $showResetPassword) {
                TextField(lang.auth.resetEmailPlaceholder, text: $resetEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                Button(lang.auth.resetButton) {
                    Task {
                        do {
                            try await authManager.resetPassword(email: resetEmail)
                            resetSent = true
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }
                Button(lang.common.cancel, role: .cancel) {}
            } message: {
                Text(lang.auth.resetMessage)
            }
            .alert(lang.auth.errorTitle, isPresented: $showError) {
                Button(lang.common.ok, role: .cancel) {}
            } message: {
                Text(errorMessage ?? lang.auth.errorUnknown)
            }
            .alert(lang.auth.resetSentTitle, isPresented: $resetSent) {
                Button(lang.common.ok, role: .cancel) {}
            } message: {
                Text(lang.auth.resetSentMessage)
            }
        }
    }

    private func performLogin() {
        var actualEmail = email.trimmingCharacters(in: .whitespaces)
        var actualPassword = password
        if actualEmail.lowercased() == "demo" && actualPassword == "demo" {
            actualEmail = "gardencalendar.demo@gmail.com"
            actualPassword = "GardenDemo2026!"
        }
        Task {
            do {
                try await authManager.signIn(email: actualEmail, password: actualPassword)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func performAppleSignIn() {
        Task {
            do {
                let (idToken, nonce) = try await AppleSignInCoordinator().signIn()
                try await authManager.signInWithApple(idToken: idToken, nonce: nonce)
            } catch let error as ASAuthorizationError where error.code == .canceled {
                // Utente annulla il pannello Apple: nessun alert.
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager.shared)
        .environment(LanguageManager.shared)
}
