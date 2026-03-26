import Foundation
import SwiftData

@MainActor
class FragmentEditorViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var body: String = ""
    @Published var tagInput: String = ""
    @Published var tags: [String] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    private let repository: FragmentRepositoryProtocol
    private let aiService: AIAnalysisServiceProtocol
    private let usageLimit: UsageLimitService
    private let existingFragment: Fragment?

    init(
        fragment: Fragment? = nil,
        repository: FragmentRepositoryProtocol,
        aiService: AIAnalysisServiceProtocol,
        usageLimit: UsageLimitService
    ) {
        self.existingFragment = fragment
        self.repository = repository
        self.aiService = aiService
        self.usageLimit = usageLimit

        if let fragment = fragment {
            self.title = fragment.title
            self.body = fragment.body
            self.tags = fragment.tags
            self.tagInput = fragment.tags.joined(separator: ", ")
        }
    }

    var hasAISummary: Bool {
        existingFragment?.aiSummary != nil
    }

    /// 保存して Fragment を返す。失敗時は nil。
    @discardableResult
    func saveFragment() -> Fragment? {
        guard !body.isEmpty else {
            errorMessage = "本文は必須です"
            showError = true
            return nil
        }

        let fragment = existingFragment ?? Fragment()
        fragment.title = title
        fragment.body = body
        fragment.tags = tags
        fragment.updatedAt = Date()

        do {
            if existingFragment == nil {
                try repository.save(fragment)
            } else {
                try repository.update(fragment)
            }
            return fragment
        } catch {
            errorMessage = "保存に失敗しました"
            showError = true
            return nil
        }
    }

    func saveAndAnalyze(onComplete: @escaping () -> Void) {
        guard usageLimit.canUseAnalysis() else {
            errorMessage = "AI整理の残数に達しました"
            showError = true
            return
        }

        guard let fragment = saveFragment() else { return }

        isLoading = true
        Task {
            do {
                let response = try await aiService.analyze(fragmentText: fragment.body)
                fragment.aiSummary = response.summary
                fragment.aiQuestion = response.question
                fragment.aiClaim = response.claim
                fragment.aiImage = response.image
                fragment.aiUseCases = response.useCases
                fragment.typeRawValue = response.type.rawValue
                fragment.statusRawValue = FragmentStatus.growing.rawValue
                try repository.update(fragment)
                usageLimit.consumeAnalysis()
                isLoading = false
                onComplete()
            } catch {
                errorMessage = "AI整理に失敗しました"
                showError = true
                isLoading = false
            }
        }
    }
}
