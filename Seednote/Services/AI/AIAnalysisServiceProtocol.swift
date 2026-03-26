import Foundation

protocol AIAnalysisServiceProtocol {
    func analyze(fragmentText: String) async throws -> AIAnalysisResponse
    func generateDraft(fragmentText: String, template: TemplateType) async throws -> DraftGenerationResponse
}
