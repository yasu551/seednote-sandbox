import Foundation

struct AIAnalyzeResponseDTO: Codable {
    let summary: String
    let type: String
    let question: String
    let claim: String
    let image: String
    let useCases: [String]

    func toDomain() throws -> AIAnalysisResponse {
        guard let fragmentType = FragmentType(rawValue: type) else {
            throw AIServiceError.decodingError
        }

        return AIAnalysisResponse(
            summary: summary,
            type: fragmentType,
            question: question,
            claim: claim,
            image: image,
            useCases: useCases
        )
    }
}
