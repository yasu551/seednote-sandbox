import SwiftUI
import SwiftData

@main
struct SeednoteApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(AppRouter.shared.modelContainer)
    }
}
