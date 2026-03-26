import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showAddSheet = false
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: Spacing.md) {
                        SearchBarView(text: $viewModel.searchText, placeholder: "検索...")
                        HomeFilterBar(selectedFilter: $viewModel.selectedFilter)

                        if viewModel.filteredFragments.isEmpty {
                            EmptyStateView(
                                title: "該当する断片がありません",
                                message: "検索条件またはステータスを変更してください。"
                            )
                        } else {
                            FragmentListView(
                                fragments: viewModel.filteredFragments,
                                onTapAdd: { showAddSheet = true }
                            )
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("Seednote")
            .navigationDestination(for: Fragment.self) { fragment in
                HomePlaceholderView(
                    title: fragment.title.isEmpty ? "断片詳細" : fragment.title
                )
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
                FragmentEditorView { fragment in
                    viewModel.addFragment(fragment)
                }
                .presentationDetents([.large])
            }
            .sheet(isPresented: $showSettings) {
                HomePlaceholderView(title: "設定")
            }
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.applyFilters()
            }
            .onChange(of: viewModel.selectedFilter) { _, _ in
                viewModel.applyFilters()
            }
        }
    }
}

#Preview {
    HomeView()
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
