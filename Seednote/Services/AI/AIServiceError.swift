import Foundation

enum AIServiceError: LocalizedError {
    case invalidConfiguration
    case invalidRequest
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case networkError(URLError)
    case decodingError
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "AI APIの設定が不正です"
        case .invalidRequest:
            return "AI APIへのリクエストを作成できませんでした"
        case .invalidResponse:
            return "AI APIのレスポンスが不正です"
        case let .httpError(statusCode, message):
            if let message, !message.isEmpty {
                return "AI APIエラー(\(statusCode)): \(message)"
            }
            return "AI APIエラー(\(statusCode))"
        case .networkError:
            return "AI APIへの接続に失敗しました"
        case .decodingError:
            return "AI APIのレスポンスを解釈できませんでした"
        case let .unknown(error):
            return error.localizedDescription
        }
    }
}
