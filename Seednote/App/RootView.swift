import SwiftUI
import SwiftData

struct RootView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
        .modelContainer(AppRouter.shared.modelContainer)
    }
}

#Preview {
    RootView()
}
