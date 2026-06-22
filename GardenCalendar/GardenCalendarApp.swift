import SwiftUI

@main
struct GardenCalendarApp: App {
    @State private var authManager = AuthManager.shared
    @State private var repository = SupabaseRepository.shared
    @State private var langManager = LanguageManager.shared
    @State private var catalogService = PlantCatalogService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(repository)
                .environment(langManager)
                .environment(catalogService)
                .onAppear {
                    authManager.startObserving()
                }
                .onOpenURL { url in
                    Task {
                        await authManager.handleDeepLink(url: url)
                    }
                }
        }
    }
}
