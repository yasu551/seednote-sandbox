import Foundation

class RelatedFragmentService: RelatedFragmentServiceProtocol {
    func relatedFragments(for fragment: Fragment, from fragments: [Fragment]) -> [RelatedFragment] {
        let candidates = fragments.filter { $0.id != fragment.id }
        
        let scored = candidates.map { candidate -> RelatedFragment in
            var score: Double = 0.0
            
            // タグ一致: +0.3
            let commonTags = Set(fragment.tags).intersection(Set(candidate.tags)).count
            if commonTags > 0 {
                score += Double(commonTags) * 0.3
            }
            
            // type 一致: +0.2
            if fragment.type == candidate.type && fragment.type != nil {
                score += 0.2
            }
            
            // status 一致: +0.1
            if fragment.status == candidate.status {
                score += 0.1
            }
            
            // body の共通単語: +0.2
            let fragmentWords = Set(fragment.body.split(separator: " ").map(String.init))
            let candidateWords = Set(candidate.body.split(separator: " ").map(String.init))
            let commonWords = fragmentWords.intersection(candidateWords).count
            if commonWords > 0 {
                score += min(Double(commonWords) * 0.05, 0.2)
            }
            
            return RelatedFragment(id: UUID(), fragment: candidate, score: score)
        }
        
        return scored
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
            .prefix(5)
            .map { $0 }
    }
}
