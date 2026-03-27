import Foundation

extension String {
    func tagsFromCommaSeparated() -> [String] {
        split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    func tagsToCommaSeparated(_ tags: [String]) -> String {
        tags.joined(separator: ", ")
    }

    func summarized(maxLength: Int = 50) -> String {
        if count <= maxLength { return self }
        return String(prefix(maxLength)) + "…"
    }
}
