import Foundation

class SubscriptionService: SubscriptionServiceProtocol {
    var currentTier: SubscriptionTier = .free
    
    func restorePurchases() async {
        // スタブ: 本実装不要
    }
    
    func purchasePro() async {
        // スタブ: 本実装不要
    }
}
