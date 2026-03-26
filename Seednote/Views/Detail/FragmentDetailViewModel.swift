import Foundation
import SwiftData

@MainActor
class FragmentDetailViewModel: ObservableObject {
    @Published var fragment: Fragment
    @Published var relatedFragments: [RelatedFragment] = []
    @Published var isLoading: Bool = false
    
    private let repository: FragmentRepositoryProtocol
    private let aiService: AIAnalysisServiceProtocol
    private let relatedService: RelatedFragmentServiceProtocol
    private let allFragments: [Fragment]
    
    init(
        fragment: Fragment,
        repository: FragmentRepositoryProtocol,
        aiService: AIAnalysisServiceProtocol,
        relatedService: RelatedFragmentServiceProtocol,
        allFragments: [Fragment]
    ) {
        self.fragment = fragment
        self.repository = repository
        self.aiService = aiService
        self.relatedService = relatedService
        self.allFragments = allFragments
        self.relatedFragments = relatedService.relatedFragments(for: fragment, from: allFragments)
    }
    
    func updateStatus(_ status: FragmentStatus) {
        fragment.statusRawValue = status.rawValue
        do {
            try repository.update(fragment)
        } catch {
            print("Failed to update status: \(error)")
        }
    }
    
    func reanalyzeFragment() {
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
                
                try repository.update(fragment)
                isLoading = false
            } catch {
                print("Failed to reanalyze: \(error)")
                isLoading = false
            }
        }
    }
    
    func deleteFragment() {
        do {
            try repository.delete(fragment)
        } catch {
            print("Failed to delete fragment: \(error)")
        }
    }
}
