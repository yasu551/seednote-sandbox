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
                HomePlaceholderView(title: "設定")
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(makeHomePreviewContainer())
}

private struct HomePlaceholderView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.md) {
                Image(systemName: "hammer")
                    .font(.system(size: 32))
                    .foregroundColor(Colors.textSecondary)

                Text("\(title) は仮画面です")
                    .font(Typography.title3)

                Text("TODO: 次のステップで本実装に差し替える")
                    .font(Typography.footnote)
                    .foregroundColor(Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(Spacing.lg)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
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
