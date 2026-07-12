# Google Sign-In (garden-calendar-ios) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a "Sign in with Google" button to `LoginView` that authenticates via Supabase OAuth (browser flow), reusing the existing deep-link session handling.

**Architecture:** `AuthManager.signInWithGoogle()` calls `client.auth.signInWithOAuth(provider: .google, redirectTo:)`, which opens `ASWebAuthenticationSession` internally via supabase-swift. The existing `onOpenURL` → `authManager.handleDeepLink(url:)` → `checkSession()` chain (already used by sign-up) picks up the resulting session with zero changes.

**Tech Stack:** SwiftUI, supabase-swift (`Supabase.Auth`), no new dependencies.

## Global Constraints

- No new SPM packages (Approach B chosen specifically to avoid this — see spec).
- Match existing code style: `@MainActor @Observable` AuthManager, `Task { do/catch }` pattern in views.
- Localized strings only via `Strings.swift` `Auth` struct — no hardcoded UI text.
- Redirect URL is always `garden-calendar://auth-callback` (matches existing sign-up flow, must match Supabase allowlist).

Reference spec: `docs/superpowers/specs/2026-07-12-google-signin-design.md`

---

### Task 1: External setup (Google Cloud Console + Supabase Dashboard)

**This task has no code.** It's manual configuration the user must perform before Task 4's manual test can pass. Code tasks (2, 3, 4) do not depend on this being done first — only the final end-to-end test does.

- [ ] **Step 1: Create/select Google Cloud project**
  Go to https://console.cloud.google.com/ → select existing project or create one.

- [ ] **Step 2: Configure OAuth consent screen**
  APIs & Services → OAuth consent screen → User Type "External" → fill app name, support email → save (test users not required if app stays in "Testing" publish status for personal use).

- [ ] **Step 3: Create OAuth Client ID (Web application type)**
  APIs & Services → Credentials → Create Credentials → OAuth client ID → Application type: **Web application**.
  Under "Authorized redirect URIs" add:
  ```
  https://<your-project-ref>.supabase.co/auth/v1/callback
  ```
  Replace `<your-project-ref>` with the Supabase project ref (found in Supabase Dashboard → Project Settings → General → Reference ID).
  Save. Copy the generated **Client ID** and **Client Secret**.

- [ ] **Step 4: Enable Google provider in Supabase**
  Supabase Dashboard → Authentication → Providers → Google → toggle enabled → paste Client ID and Client Secret from Step 3 → Save.

- [ ] **Step 5: Verify redirect URL allowlist**
  Supabase Dashboard → Authentication → URL Configuration → Redirect URLs → confirm `garden-calendar://auth-callback` is listed (it should already be there from the sign-up flow). If missing, add it.

---

### Task 2: Add localized string `Auth.googleSignIn`

**Files:**
- Modify: `GardenCalendar/Localization/Strings.swift:38` (struct field), `:296` (Italian value), `:536` (English value)

**Interfaces:**
- Produces: `Strings.Auth.googleSignIn: String`, accessed as `lang.auth.googleSignIn` (same pattern as `lang.auth.appleSignIn`).

- [ ] **Step 1: Add field to `Auth` struct**

In `GardenCalendar/Localization/Strings.swift`, line 38 currently reads:
```swift
        let appleSignIn: String
```
Change to:
```swift
        let appleSignIn: String
        let googleSignIn: String
```

- [ ] **Step 2: Add Italian value**

Line 296 currently reads:
```swift
            appleSignIn: "Accedi con Apple",
```
Change to:
```swift
            appleSignIn: "Accedi con Apple",
            googleSignIn: "Accedi con Google",
```

- [ ] **Step 3: Add English value**

Line 536 currently reads:
```swift
            appleSignIn: "Sign in with Apple",
```
Change to:
```swift
            appleSignIn: "Sign in with Apple",
            googleSignIn: "Sign in with Google",
```

- [ ] **Step 4: Build to verify no compile errors**

Run: `xcodebuild -scheme GardenCalendar -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -30`
Expected: `** BUILD SUCCEEDED **` (any pre-existing warnings unrelated to this change are fine; there must be no "missing argument" error for `Auth(...)`).

- [ ] **Step 5: Commit**

```bash
git add GardenCalendar/Localization/Strings.swift
git commit -m "feat(i18n): add googleSignIn string (IT/EN)"
```

---

### Task 3: `AuthManager.signInWithGoogle()`

**Files:**
- Modify: `GardenCalendar/Services/AuthManager.swift` (add method after `signInWithApple`, which ends at line 100)

**Interfaces:**
- Consumes: `client` (existing private property, `SupabaseConfig.client`), `client.auth.signInWithOAuth(provider:redirectTo:)` (supabase-swift API).
- Produces: `func signInWithGoogle() async throws` — called by `LoginView` in Task 4. Does NOT return a session or mutate `session`/`user`/`isAuthenticated` directly (the existing `handleDeepLink` → `checkSession()` chain does that once the redirect lands).

- [ ] **Step 1: Add the method**

In `GardenCalendar/Services/AuthManager.swift`, immediately after the closing brace of `signInWithApple` (currently line 100), insert:

```swift

    func signInWithGoogle() async throws {
        try await client.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "garden-calendar://auth-callback")
        )
    }
```

- [ ] **Step 2: Build to verify it compiles**

Run: `xcodebuild -scheme GardenCalendar -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -30`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add GardenCalendar/Services/AuthManager.swift
git commit -m "feat(auth): add signInWithGoogle via Supabase OAuth"
```

---

### Task 4: Google button in `LoginView`

**Files:**
- Modify: `GardenCalendar/Views/Auth/LoginView.swift:116-125` (button UI), `:183-195` (add sibling handler after `performAppleSignIn`)

**Interfaces:**
- Consumes: `authManager.signInWithGoogle() async throws` (Task 3), `lang.auth.googleSignIn` (Task 2).
- Produces: nothing consumed by later tasks — this is the last code task.

- [ ] **Step 1: Add the button below the existing Apple button**

Current code at lines 116-125:
```swift
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
```

Replace with (adds Google button right after):
```swift
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

                        // Google Sign-In button
                        Button(action: performGoogleSignIn) {
                            Label(lang.auth.googleSignIn, systemImage: "g.circle.fill")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.cardBackground)
                                .foregroundStyle(AppTheme.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.cardSecondaryWarm, lineWidth: 1))
                        }
                        .padding(.horizontal, 24)
```

- [ ] **Step 2: Add the handler**

Current code at lines 183-195:
```swift
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
```

Add immediately after (before the closing `}` of the `LoginView` struct):
```swift

    private func performGoogleSignIn() {
        Task {
            do {
                try await authManager.signInWithGoogle()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
```

- [ ] **Step 3: Build to verify it compiles**

Run: `xcodebuild -scheme GardenCalendar -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -30`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Commit**

```bash
git add "GardenCalendar/Views/Auth/LoginView.swift"
git commit -m "feat(auth): add Google Sign-In button to LoginView"
```

---

### Task 5: End-to-end manual verification

**Prerequisite:** Task 1 (external setup) must be complete, and Tasks 2-4 committed.

**Files:** none (manual test only — no automated test infrastructure exists for the auth flow in this codebase).

- [ ] **Step 1: Run app in simulator or device**

Run: `xcodebuild -scheme GardenCalendar -destination 'platform=iOS Simulator,name=iPhone 16' build` then launch via Xcode, or open the project in Xcode and hit Run.

- [ ] **Step 2: Golden path — successful Google login**

On `LoginView`, tap "Accedi con Google" / "Sign in with Google". Expected: a web sheet (`ASWebAuthenticationSession`) opens showing Google's login page. Complete login with a real Google account. Expected: sheet closes, app returns to foreground, `ContentView` shows the authenticated main tabs (not `LoginView`).

- [ ] **Step 3: Cancel path**

Tap the Google button again, then dismiss the web sheet before completing login (swipe down or tap Cancel). Expected: app returns to `LoginView` with either no alert or a generic error alert — no crash, no stuck loading state, no partial/inconsistent `isAuthenticated` state.

- [ ] **Step 4: Coexistence with email/password**

After a successful Google login, sign out (`authManager.signOut()` via Settings), then log back in with an existing email/password account. Expected: works exactly as before, unaffected by the Google changes.

- [ ] **Step 5: Confirm no regressions in Apple Sign-In**

Tap "Accedi con Apple" and confirm it still works as before (unaffected by this change, since Task 3/4 additions are purely additive).

No commit for this task (no code changes) — if any step fails, fix the relevant Task 2-4 code and re-commit there.
