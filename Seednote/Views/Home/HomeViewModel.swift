import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedFilter: FragmentStatus? = nil
    @Published var filteredFragments: [Fragment]

    private let allFragments: [Fragment]

    init(fragments: [Fragment] = PreviewData.sampleFragments) {
        self.allFragments = fragments
        self.filteredFragments = fragments
    }

    func applyFilters() {
        var result = allFragments

        if let selectedFilter {
            result = result.filter { $0.status == selectedFilter }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { fragment in
                fragment.title.localizedCaseInsensitiveContains(query)
                    || fragment.body.localizedCaseInsensitiveContains(query)
                    || fragment.tags.contains { $0.localizedCaseInsensitiveContains(query) }
            }
        }

        filteredFragments = result
    }
}
