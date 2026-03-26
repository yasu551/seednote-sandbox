import Foundation

@MainActor
class FragmentEditorViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var body: String = ""
    @Published var tagInput: String = ""
    @Published var tags: [String] = []

    private let existingFragment: Fragment?
    private let onSave: (Fragment) -> Void

    init(
        fragment: Fragment? = nil,
        onSave: @escaping (Fragment) -> Void = { _ in }
    ) {
        self.existingFragment = fragment
        self.onSave = onSave

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

    var screenTitle: String {
        existingFragment == nil ? "新規作成" : "断片を編集"
    }

    @discardableResult
    func saveFragment() -> Fragment? {
        guard canSave else {
            return nil
        }

        let fragment = existingFragment ?? Fragment()
        fragment.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        fragment.body = trimmedBody
        fragment.tags = normalizedTags
        fragment.updatedAt = Date()
        onSave(fragment)
        return fragment
    }

    @discardableResult
    func saveAndAnalyze() -> Fragment? {
        saveFragment()
    }

    private var trimmedBody: String {
        body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var normalizedTags: [String] {
        tagInput.tagsFromCommaSeparated()
    }
}
