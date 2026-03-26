import Foundation
import SwiftData

class SwiftDataFragmentRepository: FragmentRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAll() throws -> [Fragment] {
        let descriptor = FetchDescriptor<Fragment>(sortBy: [
            SortDescriptor(\.createdAt, order: .reverse)
        ])
        return try modelContext.fetch(descriptor)
    }
    
    func save(_ fragment: Fragment) throws {
        modelContext.insert(fragment)
        try modelContext.save()
    }
    
    func delete(_ fragment: Fragment) throws {
        modelContext.delete(fragment)
        try modelContext.save()
    }
    
    func update(_ fragment: Fragment) throws {
        fragment.updatedAt = Date()
        try modelContext.save()
    }
}
