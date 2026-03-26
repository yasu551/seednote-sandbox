import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var fragments: [Fragment]
    @Published var searchText: String = ""
    @Published var selectedStatus: FragmentStatus? = nil

    private let allFragments: [Fragment]

    init(fragments: [Fragment] = PreviewData.sampleFragments) {
        self.allFragments = fragments
        self.fragments = fragments
    }

    func applyFilters() {
        var result = allFragments

        if let selectedStatus {
            result = result.filter { $0.status == selectedStatus }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { fragment in
                fragment.title.localizedCaseInsensitiveContains(query)
                    || fragment.body.localizedCaseInsensitiveContains(query)
            }
        }

        fragments = result
    }
}
