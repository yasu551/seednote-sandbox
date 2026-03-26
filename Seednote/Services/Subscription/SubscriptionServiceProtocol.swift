import Foundation

enum SubscriptionTier {
    case free
    case pro
}

protocol SubscriptionServiceProtocol {
    var currentTier: SubscriptionTier { get }
    func restorePurchases() async
    func purchasePro() async
}
