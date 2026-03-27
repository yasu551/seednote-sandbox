import Foundation

struct AIDraftResponseDTO: Codable {
    let content: String

    func toDomain() -> DraftGenerationResponse {
        DraftGenerationResponse(content: content)
    }
}
