import Foundation

struct APIConfiguration {
    static let apiBaseURLKey = "SEEDNOTE_API_BASE_URL"
    static let apiTokenKey = "SEEDNOTE_API_TOKEN"
    static let useMockAIKey = "SEEDNOTE_USE_MOCK_AI"

    let baseURL: URL?
    let apiToken: String?
    let useMockAI: Bool

    static var current: APIConfiguration {
        let environment = ProcessInfo.processInfo.environment
        let info = Bundle.main.infoDictionary ?? [:]

        let baseURLText = stringValue(for: apiBaseURLKey, environment: environment, info: info)
        let apiToken = stringValue(for: apiTokenKey, environment: environment, info: info)
        let useMockAI = boolValue(for: useMockAIKey, environment: environment, info: info, defaultValue: baseURLText?.isEmpty ?? true)

        return APIConfiguration(
            baseURL: baseURLText.flatMap(URL.init(string:)),
            apiToken: apiToken,
            useMockAI: useMockAI
        )
    }

    var isRemoteEnabled: Bool {
        useMockAI == false && baseURL != nil
    }

    private static func stringValue(
        for key: String,
        environment: [String: String],
        info: [String: Any]
    ) -> String? {
        if let value = environment[key]?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty {
            return value
        }

        guard let value = info[key] as? String else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func boolValue(
        for key: String,
        environment: [String: String],
        info: [String: Any],
        defaultValue: Bool
    ) -> Bool {
        if let value = environment[key] {
            return NSString(string: value).boolValue
        }

        if let value = info[key] as? String {
            return NSString(string: value).boolValue
        }

        if let value = info[key] as? Bool {
            return value
        }

        return defaultValue
    }
}
