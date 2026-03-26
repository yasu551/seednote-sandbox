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
}
