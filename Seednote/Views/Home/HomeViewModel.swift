import Foundation
import SwiftData

@MainActor
class HomeViewModel: ObservableObject {
    @Published var fragments: [Fragment] = []
    @Published var searchText: String = ""
    @Published var selectedStatus: FragmentStatus? = nil
    
    private var allFragments: [Fragment] = []
    private let repository: FragmentRepositoryProtocol
    
    init(repository: FragmentRepositoryProtocol) {
        self.repository = repository
        loadFragments()
    }
    
    var filteredFragments: [Fragment] {
        var result = allFragments
        
        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }
        
        if !searchText.isEmpty {
            result = result.filter { fragment in
                fragment.title.contains(searchText) || 
                fragment.body.contains(searchText)
            }
        }
        
        return result
    }
    
    func loadFragments() {
        do {
            allFragments = try repository.fetchAll()
            fragments = filteredFragments
        } catch {
            print("Failed to load fragments: \(error)")
        }
    }
    
    func deleteFragment(_ fragment: Fragment) {
        do {
            try repository.delete(fragment)
            loadFragments()
        } catch {
            print("Failed to delete fragment: \(error)")
        }
    }
    
    func updateFilteredFragments() {
        fragments = filteredFragments
    }
}
