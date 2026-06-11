import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(LanguageManager.self) private var lang

    var body: some View {
        Group {
            if authManager.isLoading {
                ProgressView("Caricamento…")
                    .progressViewStyle(.circular)
            } else if !authManager.isAuthenticated {
                LoginView()
            } else {
                mainTabView
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: authManager.isLoading)
    }

    @ViewBuilder
    private var mainTabView: some View {
        TabView {
            CalendarGridView()
                .tabItem {
                    Label(lang.tabs.calendar, systemImage: "calendar")
                }

            OrtoListView()
                .tabItem {
                    Label(lang.tabs.gardens, systemImage: "leaf")
                }

            SettingsView()
                .tabItem {
                    Label(lang.tabs.settings, systemImage: "gearshape")
                }
        }
        .tint(AppTheme.primaryGreen)
    }
}
