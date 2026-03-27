import Foundation

struct AIAPIRequestFactory {
    let configuration: APIConfiguration
    let encoder: JSONEncoder

    init(configuration: APIConfiguration, encoder: JSONEncoder = JSONEncoder()) {
        self.configuration = configuration
        self.encoder = encoder
    }

    func makeAnalyzeRequest(payload: AIAnalyzeRequestDTO) throws -> URLRequest {
        try makeRequest(path: "/v1/analyze", payload: payload)
    }

    func makeDraftRequest(payload: AIDraftRequestDTO) throws -> URLRequest {
        try makeRequest(path: "/v1/drafts", payload: payload)
    }

    private func makeRequest<T: Encodable>(path: String, payload: T) throws -> URLRequest {
        guard let baseURL = configuration.baseURL else {
            throw AIServiceError.invalidConfiguration
        }

        let endpoint = baseURL.appending(path: path)
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = configuration.apiToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            request.httpBody = try encoder.encode(payload)
            return request
        } catch {
            throw AIServiceError.invalidRequest
        }
    }
}
