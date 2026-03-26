import Foundation
import SwiftData

@MainActor
class GeneratedDraftViewModel: ObservableObject {
    var draft: GeneratedDraft
    @Published var isLoading: Bool = false
    @Published var draftContent: String = ""
    
    private let aiService: AIAnalysisServiceProtocol
    private let repository: FragmentRepositoryProtocol
    private let usageLimit: UsageLimitService
    private let fragment: Fragment
    
    init(
        fragment: Fragment,
        template: TemplateType,
        aiService: AIAnalysisServiceProtocol,
        repository: FragmentRepositoryProtocol,
        usageLimit: UsageLimitService
    ) {
        self.fragment = fragment
        self.aiService = aiService
        self.repository = repository
        self.usageLimit = usageLimit
        self.draft = GeneratedDraft(
            fragmentID: fragment.id,
            templateRawValue: template.rawValue
        )
    }
    
    func generateDraft() {
        guard let template = draft.template else { return }
        
        isLoading = true
        
        Task {
            do {
                let response = try await aiService.generateDraft(
                    fragmentText: fragment.body,
                    template: template
                )
                
                draft.content = response.content
                draftContent = response.content
                usageLimit.consumeTemplate()
                isLoading = false
            } catch {
                print("Failed to generate draft: \(error)")
                isLoading = false
            }
        }
    }
    
    func copyToClipboard() {
        ClipboardService.copy(draftContent)
    }
    
    func saveAsNewFragment() {
        let newFragment = Fragment(
            title: "[\(draft.template?.displayName ?? "ドラフト")] \(fragment.title)",
            body: draftContent,
            statusRawValue: FragmentStatus.unprocessed.rawValue
        )
        
        do {
            try repository.save(newFragment)
        } catch {
            print("Failed to save new fragment: \(error)")
        }
    }
}
