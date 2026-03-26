import Foundation

enum FragmentType: String, CaseIterable {
    case question = "question"
    case claim = "claim"
    case idea = "idea"
    case world = "world"
    case observation = "observation"
    
    var displayName: String {
        switch self {
        case .question:
            return "質問"
        case .claim:
            return "主張"
        case .idea:
            return "アイデア"
        case .world:
            return "世界観"
        case .observation:
            return "観察"
        }
    }
}
