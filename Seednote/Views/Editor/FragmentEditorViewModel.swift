import Foundation
import SwiftData

@MainActor
class FragmentEditorViewModel: ObservableObject {
    @Published var fragment: Fragment
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    private let repository: FragmentRepositoryProtocol
    private let aiService: AIAnalysisServiceProtocol
    private let usageLimit: UsageLimitService
    
    private let isNewFragment: Bool
    
    init(
        fragment: Fragment? = nil,
        repository: FragmentRepositoryProtocol,
        aiService: AIAnalysisServiceProtocol,
        usageLimit: UsageLimitService
    ) {
        if let fragment = fragment {
            self.fragment = fragment
            self.isNewFragment = false
        } else {
            self.fragment = Fragment()
            self.isNewFragment = true
        }
        self.repository = repository
        self.aiService = aiService
        self.usageLimit = usageLimit
    }
    
    func saveFragment() {
        guard !fragment.body.isEmpty else {
            errorMessage = "本文は必須です"
            showError = true
            return
        }
        
        do {
            if isNewFragment {
                try repository.save(fragment)
            } else {
                try repository.update(fragment)
            }
        } catch {
            errorMessage = "保存に失敗しました"
            showError = true
        }
    }
    
    func saveAndAnalyze() {
        guard usageLimit.canUseAnalysis() else {
            errorMessage = "AI整理の残数に達しました"
            showError = true
            return
        }
        
        saveFragment()
        analyzeFragment()
    }
    
    func analyzeFragment() {
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
            } catch {
                errorMessage = "AI整理に失敗しました"
                showError = true
                isLoading = false
            }
        }
    }
}
