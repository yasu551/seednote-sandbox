import Foundation

class RelatedFragmentService: RelatedFragmentServiceProtocol {
    func relatedFragments(for fragment: Fragment, from fragments: [Fragment]) -> [RelatedFragment] {
        let candidates = fragments.filter { $0.id != fragment.id }
        let fragmentNGrams = bodyNGrams(from: fragment.body)

        let scored = candidates.map { candidate -> RelatedFragment in
            var score: Double = 0.0

            let commonTags = Set(fragment.tags).intersection(Set(candidate.tags)).count
            if commonTags > 0 {
                score += Double(commonTags) * 0.2
            }

            if fragment.type == candidate.type && fragment.type != nil {
                score += 0.3
            }

            let candidateNGrams = bodyNGrams(from: candidate.body)
            let commonNGrams = fragmentNGrams.intersection(candidateNGrams).count
            if commonNGrams > 0 {
                score += min(Double(commonNGrams) * 0.05, 0.4)
            }

            return RelatedFragment(id: UUID(), fragment: candidate, score: score)
        }

        return scored
            .filter { $0.score > 0 }
            .sorted {
                if $0.score == $1.score {
                    return $0.fragment.updatedAt > $1.fragment.updatedAt
                }
                return $0.score > $1.score
            }
            .prefix(3)
            .map { $0 }
    }

    private func bodyNGrams(from body: String) -> Set<String> {
        let normalized = body
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .joined()
        let characters = Array(normalized)

        guard characters.count >= 2 else {
            return []
        }

        return Set(
            (0..<(characters.count - 1)).map { index in
                String(characters[index...index + 1])
            }
        )
    }
}
