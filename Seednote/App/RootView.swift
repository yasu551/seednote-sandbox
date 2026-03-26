import SwiftUI
import SwiftData

struct RootView: View {
    @StateObject private var router = AppRouter.shared
    
    var body: some View {
        NavigationStack {
            HomeView()
                .environmentObject(router.usageLimitService)
        }
        .modelContainer(router.modelContainer)
    }
}

#Preview {
    RootView()
}
