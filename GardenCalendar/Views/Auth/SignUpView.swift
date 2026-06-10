import SwiftUI

/// Schermata di registrazione con validazione email, password match e conferma.
struct SignUpView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showSuccess = false

    private var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }

    private var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    private var passwordValid: Bool {
        password.count >= 6
    }

    private var canSubmit: Bool {
        isValidEmail && passwordsMatch && passwordValid && !authManager.isLoading
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundCream
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)

                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 56))
                        .foregroundStyle(AppTheme.primaryGreen)

                    Text("Crea il tuo account")
                        .font(.lora(28))
                        .foregroundStyle(AppTheme.textPrimary)

                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .padding()
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.cardSecondaryWarm, lineWidth: 1))

                            if !email.isEmpty && !isValidEmail {
                                Text("Inserisci un indirizzo email valido")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .padding(.leading, 4)
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            SecureField("Password", text: $password)
                                .textContentType(.newPassword)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.cardSecondaryWarm, lineWidth: 1))

                            if !password.isEmpty && !passwordValid {
                                Text("Minimo 6 caratteri")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .padding(.leading, 4)
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            SecureField("Conferma password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.cardSecondaryWarm, lineWidth: 1))

                            if !confirmPassword.isEmpty && !passwordsMatch {
                                Text("Le password non coincidono")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .padding(.leading, 4)
                            }
                        }
                    }

                    Button(action: performSignUp) {
                        Group {
                            if authManager.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Registrati")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(canSubmit ? AppTheme.primaryGreen : Color.gray)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                    }
                    .disabled(!canSubmit)

                    Button(action: { dismiss() }) {
                        Text("Hai già un account? **Accedi**")
                            .font(.dmSans(14))
                            .foregroundStyle(AppTheme.primaryGreen)
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Registrazione")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Errore", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Si è verificato un errore.")
        }
        .alert("Registrazione completata", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("Account creato con successo. Benvenuto!")
        }
    }

    private func performSignUp() {
        Task {
            do {
                try await authManager.signUp(email: email.trimmingCharacters(in: .whitespaces), password: password)
                showSuccess = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environment(AuthManager.shared)
    }
}
