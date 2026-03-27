import Foundation

final class RemoteAIAnalysisService: AIAnalysisServiceProtocol {
    private let client: AIAPIClient
    private let requestFactory: AIAPIRequestFactory
    private let decoder: JSONDecoder

    init(
        configuration: APIConfiguration,
        client: AIAPIClient = URLSessionAIAPIClient(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.client = client
        self.requestFactory = AIAPIRequestFactory(configuration: configuration)
        self.decoder = decoder
    }

    func analyze(fragmentText: String) async throws -> AIAnalysisResponse {
        let request = try requestFactory.makeAnalyzeRequest(
            payload: AIAnalyzeRequestDTO(fragmentText: fragmentText)
        )
        let responseDTO: AIAnalyzeResponseDTO = try await send(request)
        return try responseDTO.toDomain()
    }

    func generateDraft(fragmentText: String, template: TemplateType) async throws -> DraftGenerationResponse {
        let request = try requestFactory.makeDraftRequest(
            payload: AIDraftRequestDTO(fragmentText: fragmentText, template: template.rawValue)
        )
        let responseDTO: AIDraftResponseDTO = try await send(request)
        return responseDTO.toDomain()
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await client.send(request)

        guard (200..<300).contains(response.statusCode) else {
            let message = try? decoder.decode(AIErrorResponseDTO.self, from: data)
            throw AIServiceError.httpError(statusCode: response.statusCode, message: message?.error.message)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AIServiceError.decodingError
        }
    }
}

private struct AIErrorResponseDTO: Decodable {
    struct ErrorPayload: Decodable {
        let message: String
    }

    let error: ErrorPayload
}
