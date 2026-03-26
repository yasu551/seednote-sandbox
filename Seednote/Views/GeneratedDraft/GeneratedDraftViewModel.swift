import Foundation

@MainActor
class GeneratedDraftViewModel: ObservableObject {
    var draft: GeneratedDraft
    @Published var isLoading: Bool = false
    @Published var draftContent: String = ""
    
    private let aiService: AIAnalysisServiceProtocol
    private let repository: FragmentRepositoryProtocol
    private let usageLimit: UsageLimitService
    private let fragment: Fragment
    private let clipboardService: ClipboardServiceProtocol
    
    init(
        fragment: Fragment,
        template: TemplateType,
        aiService: AIAnalysisServiceProtocol,
        repository: FragmentRepositoryProtocol,
        usageLimit: UsageLimitService,
        clipboardService: ClipboardServiceProtocol = ClipboardService.shared
    ) {
        self.fragment = fragment
        self.aiService = aiService
        self.repository = repository
        self.usageLimit = usageLimit
        self.clipboardService = clipboardService
        self.draft = GeneratedDraft(
            fragmentID: fragment.id,
            templateRawValue: template.rawValue
        )
    }

    func generateDraft() async {
        guard let template = draft.template else { return }
        guard !isLoading else { return }

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let response = try await aiService.generateDraft(
                fragmentText: fragment.body,
                template: template
            )

            draft.content = response.content
            draftContent = response.content
            usageLimit.consumeTemplate()
        } catch {
            print("Failed to generate draft: \(error)")
        }
    }
    
    func copyToClipboard() {
        clipboardService.copy(draftContent)
    }
    
    func saveAsNewFragment() -> Bool {
        let newFragment = Fragment(
            title: newFragmentTitle,
            body: draftContent,
            statusRawValue: FragmentStatus.unprocessed.rawValue
        )
        
        do {
            try repository.save(newFragment)
            return true
        } catch {
            print("Failed to save new fragment: \(error)")
            return false
        }
    }

    private var newFragmentTitle: String {
        let templateName = draft.template?.displayName ?? "ドラフト"
        let originalTitle = fragment.title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !originalTitle.isEmpty else {
            return templateName
        }

        return "[\(templateName)] \(originalTitle)"
    }
}
