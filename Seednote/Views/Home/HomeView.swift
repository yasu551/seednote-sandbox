import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Query(sort: [SortDescriptor(\Fragment.updatedAt, order: .reverse)])
    private var fragments: [Fragment]
    @State private var showAddSheet = false
    @State private var showSettings = false
    
    var body: some View {
        let filteredFragments = viewModel.filteredFragments(from: fragments)

        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: Spacing.md) {
                        SearchBarView(text: $viewModel.searchText, placeholder: "検索...")
                        HomeFilterBar(selectedFilter: $viewModel.selectedFilter)

                        if fragments.isEmpty {
                            FragmentListView(
                                fragments: [],
                                onTapAdd: { showAddSheet = true }
                            )
                        } else if filteredFragments.isEmpty {
                            EmptyStateView(
                                title: "該当する断片がありません",
                                message: "検索条件またはステータスを変更してください。"
                            )
                        } else {
                            FragmentListView(
                                fragments: filteredFragments,
                                onTapAdd: { showAddSheet = true }
                            )
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("Seednote")
            .navigationDestination(for: Fragment.self) { fragment in
                FragmentDetailView(fragment: fragment)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                FragmentEditorView()
                .presentationDetents([.large])
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .presentationDetents([.large])
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(makeHomePreviewContainer())
}

@MainActor
private func makeHomePreviewContainer() -> ModelContainer {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Fragment.self,
        GeneratedDraft.self,
        configurations: configuration
    )

    PreviewData.sampleFragments.forEach { fragment in
        container.mainContext.insert(
            Fragment(
                id: fragment.id,
                title: fragment.title,
                body: fragment.body,
                createdAt: fragment.createdAt,
                updatedAt: fragment.updatedAt,
                statusRawValue: fragment.statusRawValue,
                typeRawValue: fragment.typeRawValue,
                tags: fragment.tags,
                aiSummary: fragment.aiSummary,
                aiQuestion: fragment.aiQuestion,
                aiClaim: fragment.aiClaim,
                aiImage: fragment.aiImage,
                aiUseCases: fragment.aiUseCases
            )
        )
    }

    return container
}
