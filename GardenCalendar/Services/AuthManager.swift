import Foundation
import Supabase
import Observation

@MainActor
@Observable
final class AuthManager {
    static let shared = AuthManager()

    private let client = SupabaseConfig.client

    var session: Session?
    var user: User?
    var isAuthenticated: Bool = false
    var isLoading: Bool = true
    var isAdmin: Bool = false

    private var observationTask: Task<Void, Never>?

    private init() {}

    /// Osserva i cambi di stato auth (refresh token, signOut, scadenza sessione).
    /// Senza questo, una sessione persa a metà uso lascia `isAuthenticated = true`
    /// stale: l'UI mostra le tab ma il client invia richieste anon → RLS 42501.
    func startObserving() {
        guard observationTask == nil else { return }
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await (event, session) in client.auth.authStateChanges {
                switch event {
                case .initialSession, .signedIn, .tokenRefreshed, .userUpdated:
                    self.applySession(session)
                case .signedOut:
                    self.applySession(nil)
                default:
                    break
                }
                self.isLoading = false
            }
        }
    }

    private func applySession(_ session: Session?) {
        self.session = session
        self.user = session?.user
        self.isAuthenticated = session != nil
        self.isAdmin = session?.user.userMetadata["is_admin"]?.boolValue ?? false
    }

    func checkSession() async {
        isLoading = true
        do {
            let currentSession = try await client.auth.session
            self.session = currentSession
            self.user = currentSession.user
            self.isAuthenticated = true
            self.isAdmin = currentSession.user.userMetadata["is_admin"]?.boolValue ?? false
        } catch {
            session = nil
            user = nil
            isAuthenticated = false
            isAdmin = false
        }
        isLoading = false
    }

    func signIn(email: String, password: String) async throws {
        let result = try await client.auth.signIn(email: email, password: password)
        session = result
        user = result.user
        isAuthenticated = true
        isAdmin = result.user.userMetadata["is_admin"]?.boolValue ?? false
    }

    func signUp(email: String, password: String) async throws {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            redirectTo: URL(string: "garden-calendar://auth-callback")
        )
        if let s = response.session {
            session = s
            user = s.user
            isAuthenticated = true
            isAdmin = s.user.userMetadata["is_admin"]?.boolValue ?? false
        }
    }

    func handleDeepLink(url: URL) async {
        client.auth.handle(url)
        await checkSession()
    }

    func signInWithApple(idToken: String, nonce: String) async throws {
        let result = try await client.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: idToken, nonce: nonce))
        session = result
        user = result.user
        isAuthenticated = true
        isAdmin = result.user.userMetadata["is_admin"]?.boolValue ?? false
    }

    func signOut() async {
        try? await client.auth.signOut()
        session = nil
        user = nil
        isAuthenticated = false
        isAdmin = false
    }

    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
}
