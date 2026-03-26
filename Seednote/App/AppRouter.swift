import Foundation
import SwiftData

class AppRouter {
    static let shared = AppRouter()
    
    lazy var repository: FragmentRepositoryProtocol = {
        return SwiftDataFragmentRepository(modelContext: ModelContext(modelContainer))
    }()
    
    lazy var aiService: AIAnalysisServiceProtocol = {
        return MockAIAnalysisService()
    }()
    
    lazy var relatedService: RelatedFragmentServiceProtocol = {
        return RelatedFragmentService()
    }()
    
    lazy var subscriptionService: SubscriptionServiceProtocol = {
        return SubscriptionService()
    }()
    
    lazy var usageLimitService: UsageLimitService = {
        return UsageLimitService()
    }()
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(
                for: Fragment.self, GeneratedDraft.self,
                configurations: config
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
}
