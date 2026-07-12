# Google Sign-In — garden-calendar-ios

Data: 2026-07-12

## Contesto

garden-calendar-ios usa Supabase Auth con email/password (`AuthManager.swift`) e Apple Sign-In nativo (`AppleSignInCoordinator.swift` + `AuthManager.signInWithApple(idToken:nonce:)`, bottone in `LoginView.swift`). Non esiste ancora login Google.

## Obiettivo

Aggiungere un bottone "Accedi con Google" in `LoginView.swift` che autentica l'utente tramite Supabase, riusando la stessa sessione/stato di `AuthManager`.

## Approccio scelto: OAuth via browser (Supabase `signInWithOAuth`)

Alternativa scartata: SDK nativo `GoogleSignIn-iOS` (mirror esatto del pattern Apple). Scartata perché richiede più setup esterno (package SPM, Info.plist con URL scheme reversed client ID e `GIDClientID`, Client ID Google Cloud di tipo iOS). L'approccio OAuth via browser riusa l'infrastruttura di deep-link già esistente e richiede solo un Client ID Google di tipo Web.

### Flusso

1. Utente tocca bottone Google in `LoginView`.
2. `AuthManager.signInWithGoogle()` chiama `client.auth.signInWithOAuth(provider: .google, redirectTo: URL(string: "garden-calendar://auth-callback"))`.
3. Supabase-swift apre `ASWebAuthenticationSession` con la pagina di login Google.
4. Utente completa login Google, Google reindirizza a Supabase, Supabase reindirizza a `garden-calendar://auth-callback`.
5. `onOpenURL` in `GardenCalendarApp.swift` (già esistente) intercetta l'URL e chiama `authManager.handleDeepLink(url:)`, che già gestisce sessione via `client.auth.handle(url)` + `checkSession()`.

Nessuna modifica necessaria a `handleDeepLink` o `onOpenURL`.

## Modifiche codice

- **`AuthManager.swift`**: nuovo metodo
  ```swift
  func signInWithGoogle() async throws {
      try await client.auth.signInWithOAuth(
          provider: .google,
          redirectTo: URL(string: "garden-calendar://auth-callback")
      )
  }
  ```
  Non serve aggiornare `session`/`user`/`isAuthenticated` manualmente: il flusso passa da `handleDeepLink` → `checkSession()`, che li imposta già.

- **`LoginView.swift`**: nuovo bottone sotto quello Apple (stesso stile pill), es. icona `g.circle.fill` o testo, chiama `performGoogleSignIn()` che invoca `authManager.signInWithGoogle()` in un `Task`, cattura errori con lo stesso pattern di `performAppleSignIn` (senza il caso speciale "canceled" di ASAuthorizationError, dato che qui l'annullamento produce un errore generico Supabase/URLError).

- **Strings.swift**: nuova stringa `auth.googleSignIn` (IT/EN), es. "Accedi con Google" / "Sign in with Google".

## Setup esterno richiesto (guida passo-passo in fase di implementazione)

1. **Google Cloud Console**: creare/riusare progetto, configurare OAuth consent screen, creare Client ID tipo **Web application**, aggiungere come redirect URI autorizzato: `https://<project-ref>.supabase.co/auth/v1/callback`.
2. **Supabase Dashboard** → Authentication → Providers → Google: abilitare, incollare Client ID + Client Secret dal punto 1.
3. Verificare che `garden-calendar://auth-callback` sia già in allowlist redirect URLs di Supabase (probabile, già usato da `signUp`).

## Error handling

Stesso pattern esistente: `try/catch` nel `Task`, popola `errorMessage` + `showError` (alert già presente in `LoginView`). Nessun caso speciale per annullamento (a differenza di Apple `.canceled`).

## Testing

Manuale (nessun test automatico esistente per il flusso auth):
- Tap bottone Google → completa login in browser → verificare redirect e sessione attiva (tab principali visibili, non schermata login).
- Annullare il login Google a metà → verificare che l'app mostri errore o torni a `LoginView` senza stato inconsistente.
- Verificare che login Google e login email/password coesistano senza conflitti (stesso `AuthManager`).

## Fuori scope

- Google Sign-In su budget365iOS (progetto separato, spec successiva).
- SDK nativo Google (Approccio A, scartato).
