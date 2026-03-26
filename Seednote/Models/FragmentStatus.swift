import Foundation

enum FragmentStatus: String, CaseIterable {
    case unprocessed = "unprocessed"
    case growing = "growing"
    case used = "used"
    
    var displayName: String {
        switch self {
        case .unprocessed:
            return "未整理"
        case .growing:
            return "育成中"
        case .used:
            return "使った"
        }
    }
}
