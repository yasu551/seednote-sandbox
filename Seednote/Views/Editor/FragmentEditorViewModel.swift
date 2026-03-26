import Foundation

@MainActor
class FragmentEditorViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var body: String = ""
    @Published var tagInput: String = ""
    @Published var tags: [String] = []
    @Published var isLoading: Bool = false

    private let existingFragment: Fragment?
    private let onSave: (Fragment) -> Void
    private let aiService: AIAnalysisServiceProtocol
    private var currentFragment: Fragment?
    private var hasPersistedFragment: Bool

    init(
        fragment: Fragment? = nil,
        aiService: AIAnalysisServiceProtocol? = nil,
        onSave: @escaping (Fragment) -> Void = { _ in }
    ) {
        self.existingFragment = fragment
        self.aiService = aiService ?? AppRouter.shared.aiService
        self.onSave = onSave
        self.currentFragment = fragment
        self.hasPersistedFragment = fragment != nil

        if let fragment {
            title = fragment.title
            body = fragment.body
            tags = fragment.tags
            tagInput = fragment.tags.joined(separator: ", ")
        }
    }

    var canSave: Bool {
        !trimmedBody.isEmpty
    }

    var isEditing: Bool {
        existingFragment != nil
    }

    var shouldUpdatePersistedFragment: Bool {
        existingFragment != nil || hasPersistedFragment
    }

    var screenTitle: String {
        existingFragment == nil ? "新規作成" : "断片を編集"
    }

    @discardableResult
    func saveFragment() -> Fragment? {
        guard canSave else {
            return nil
        }

        let fragment = currentFragment ?? Fragment()
        fragment.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        fragment.body = trimmedBody
        fragment.tags = normalizedTags
        fragment.updatedAt = Date()
        currentFragment = fragment
        onSave(fragment)
        return fragment
    }

    func markAsPersisted() {
        hasPersistedFragment = true
    }

    func analyzeFragment(_ fragment: Fragment) async throws {
        guard !isLoading else { return }

        isLoading = true

        defer {
            isLoading = false
        }

        let response = try await aiService.analyze(fragmentText: fragment.body)
        fragment.aiSummary = response.summary
        fragment.aiQuestion = response.question
        fragment.aiClaim = response.claim
        fragment.aiImage = response.image
        fragment.aiUseCases = response.useCases
        fragment.typeRawValue = response.type.rawValue
    }

    private var trimmedBody: String {
        body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var normalizedTags: [String] {
        tagInput.tagsFromCommaSeparated()
    }
}
