import SwiftUI

@main
struct GardenCalendarApp: App {
    @State private var authManager = AuthManager.shared
    @State private var repository = SupabaseRepository.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(repository)
                .onAppear {
                    Task {
                        await authManager.checkSession()
                    }
                }
                .onOpenURL { url in
                    Task {
                        await authManager.handleDeepLink(url: url)
                    }
                }
        }
    }
}
