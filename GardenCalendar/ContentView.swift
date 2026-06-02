import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) private var authManager

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
                    Label("Calendario", systemImage: "calendar")
                }

            OrtoListView()
                .tabItem {
                    Label("Orti", systemImage: "leaf")
                }

            SettingsView()
                .tabItem {
                    Label("Impostazioni", systemImage: "gearshape")
                }
        }
        .tint(AppTheme.primaryGreen)
    }
}
