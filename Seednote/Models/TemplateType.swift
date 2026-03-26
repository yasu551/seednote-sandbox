import Foundation

enum TemplateType: String, CaseIterable {
    case essayOutline = "essayOutline"
    case shortStoryCore = "shortStoryCore"
    case appIdea = "appIdea"
    
    var displayName: String {
        switch self {
        case .essayOutline:
            return "エッセイ骨子"
        case .shortStoryCore:
            return "短編の核"
        case .appIdea:
            return "アプリ案"
        }
    }
}
