import Foundation
import SwiftData

@MainActor
class AppRouter {
    enum Route: Hashable {
        case home
    }

    static let shared = AppRouter()

    private let apiConfiguration: APIConfiguration
    
    lazy var repository: FragmentRepositoryProtocol = {
        return SwiftDataFragmentRepository(modelContext: modelContainer.mainContext)
    }()
    
    lazy var aiService: AIAnalysisServiceProtocol = {
        return AIAnalysisService(configuration: apiConfiguration)
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
    
    init(configuration: APIConfiguration = .current) {
        self.apiConfiguration = configuration

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
