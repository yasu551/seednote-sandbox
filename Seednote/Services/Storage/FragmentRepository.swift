import SwiftData

enum FragmentRepository {
    static func make(modelContext: ModelContext) -> FragmentRepositoryProtocol {
        SwiftDataFragmentRepository(modelContext: modelContext)
    }
}
