import Foundation

struct URLSessionAIAPIClient: AIAPIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIServiceError.invalidResponse
            }

            return (data, httpResponse)
        } catch let error as AIServiceError {
            throw error
        } catch let error as URLError {
            throw AIServiceError.networkError(error)
        } catch {
            throw AIServiceError.unknown(error)
        }
    }
}
