import Foundation

struct AIAnalysisResponse {
    let summary: String
    let type: FragmentType
    let question: String
    let claim: String
    let image: String
    let useCases: [String]
}
