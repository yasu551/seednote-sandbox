import Foundation

class UsageLimitService {
    @Published private var analysisUsedCount: Int = 0
    @Published private var templateUsedCount: Int = 0
    
    private let maxAnalysisPerMonth = 10
    private let maxTemplatePerMonth = 5
    
    func canUseAnalysis() -> Bool {
        analysisUsedCount < maxAnalysisPerMonth
    }
    
    func canUseTemplate() -> Bool {
        templateUsedCount < maxTemplatePerMonth
    }
    
    func analysisRemaining() -> Int {
        max(0, maxAnalysisPerMonth - analysisUsedCount)
    }
    
    func templateRemaining() -> Int {
        max(0, maxTemplatePerMonth - templateUsedCount)
    }
    
    func consumeAnalysis() {
        analysisUsedCount += 1
    }
    
    func consumeTemplate() {
        templateUsedCount += 1
    }
    
    func resetMonthly() {
        analysisUsedCount = 0
        templateUsedCount = 0
    }
}
