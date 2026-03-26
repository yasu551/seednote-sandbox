import Foundation
import SwiftData

@MainActor
class FragmentDetailViewModel: ObservableObject {
    @Published var fragment: Fragment
    @Published var relatedFragments: [RelatedFragment] = []
    @Published var isLoading: Bool = false
    @Published var usageLimitMessage: String?

    let reuseTemplates: [TemplateType] = [.essayOutline, .shortStoryCore, .appIdea]
    
    private let repository: FragmentRepositoryProtocol
    private let aiService: AIAnalysisServiceProtocol
    private let relatedService: RelatedFragmentServiceProtocol
    private let usageLimitService: UsageLimitService
    private let allFragments: [Fragment]
    private var relatedCandidates: [Fragment]
    
    init(
        fragment: Fragment,
        repository: FragmentRepositoryProtocol,
        aiService: AIAnalysisServiceProtocol,
        relatedService: RelatedFragmentServiceProtocol,
        allFragments: [Fragment],
        usageLimitService: UsageLimitService? = nil
    ) {
        self.fragment = fragment
        self.repository = repository
        self.aiService = aiService
        self.relatedService = relatedService
        self.usageLimitService = usageLimitService ?? AppRouter.shared.usageLimitService
        self.allFragments = allFragments
        self.relatedCandidates = allFragments
        refreshRelatedFragments()
    }

    var displayDateText: String {
        fragment.updatedAt.formattedShort()
    }

    func applyEditedFragment(_ editedFragment: Fragment) {
        fragment = editedFragment
        refreshRelatedFragments()
    }
    
    func updateStatus(_ status: FragmentStatus) {
        fragment.statusRawValue = status.rawValue
        do {
            try repository.update(fragment)
        } catch {
            print("Failed to update status: \(error)")
        }
    }
    
    func reanalyzeFragment() async {
        guard !isLoading else { return }
        guard usageLimitService.canUseAnalysis() else {
            usageLimitMessage = "AI整理の無料回数を使い切りました"
            return
        }

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let response = try await aiService.analyze(fragmentText: fragment.body)

            fragment.aiSummary = response.summary
            fragment.aiQuestion = response.question
            fragment.aiClaim = response.claim
            fragment.aiImage = response.image
            fragment.aiUseCases = response.useCases
            fragment.typeRawValue = response.type.rawValue
            usageLimitService.consumeAnalysis()

            try repository.update(fragment)
            refreshRelatedFragments()
        } catch {
            print("Failed to reanalyze: \(error)")
        }
    }
    
    func deleteFragment() -> Bool {
        do {
            try repository.delete(fragment)
            return true
        } catch {
            print("Failed to delete fragment: \(error)")
            return false
        }
    }

    private func refreshRelatedFragments() {
        let candidates = loadRelatedCandidates()
        relatedCandidates = candidates
        relatedFragments = relatedService.relatedFragments(for: fragment, from: candidates)
    }

    private func loadRelatedCandidates() -> [Fragment] {
        if !allFragments.isEmpty {
            return allFragments
        }

        do {
            return try repository.fetchAll()
        } catch {
            print("Failed to fetch related fragment candidates: \(error)")
            return relatedCandidates
        }
    }
}
