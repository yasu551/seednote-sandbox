import Foundation

final class AIAnalysisService: AIAnalysisServiceProtocol {
    enum Mode {
        case mock
        case remote
    }

    private let implementation: AIAnalysisServiceProtocol
    let mode: Mode

    init(
        configuration: APIConfiguration = .current,
        client: AIAPIClient = URLSessionAIAPIClient()
    ) {
        if configuration.isRemoteEnabled {
            mode = .remote
            implementation = RemoteAIAnalysisService(
                configuration: configuration,
                client: client
            )
        } else {
            mode = .mock
            implementation = MockAIAnalysisService()
        }
    }

    init(implementation: AIAnalysisServiceProtocol) {
        self.implementation = implementation
        self.mode = .mock
    }

    func analyze(fragmentText: String) async throws -> AIAnalysisResponse {
        try await implementation.analyze(fragmentText: fragmentText)
    }

    func generateDraft(fragmentText: String, template: TemplateType) async throws -> DraftGenerationResponse {
        try await implementation.generateDraft(fragmentText: fragmentText, template: template)
    }
}
