import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var subscriptionTier: SubscriptionTier = .free
    @Published var analysisRemaining: Int = 10
    @Published var templateRemaining: Int = 5
    
    private let subscriptionService: SubscriptionServiceProtocol
    private let usageLimitService: UsageLimitService
    
    init(
        subscriptionService: SubscriptionServiceProtocol,
        usageLimitService: UsageLimitService
    ) {
        self.subscriptionService = subscriptionService
        self.usageLimitService = usageLimitService
        self.subscriptionTier = subscriptionService.currentTier
        self.analysisRemaining = usageLimitService.analysisRemaining()
        self.templateRemaining = usageLimitService.templateRemaining()
    }
}
