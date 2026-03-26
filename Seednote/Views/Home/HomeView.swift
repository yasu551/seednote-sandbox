import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showEditor = false
    @State private var showSettings = false
    @State private var navigationPath: [Fragment] = []
    
    private let repository: FragmentRepositoryProtocol
    
    init() {
        let repository = SwiftDataFragmentRepository(
            modelContext: ModelContext(AppRouter.shared.modelContainer)
        )
        self.repository = repository
        _viewModel = StateObject(wrappedValue: HomeViewModel(repository: repository))
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(Colors.primary)
                    }
                    
                    Text("Seednote")
                        .font(Typography.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: { showEditor = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Colors.primary)
                    }
                }
                .padding(Spacing.md)
                .background(Colors.background)
                
                ScrollView {
                    VStack(spacing: Spacing.md) {
                        // Search Bar
                        SearchBarView(text: $viewModel.searchText, placeholder: "検索...")
                            .padding(Spacing.md)
                            .onChange(of: viewModel.searchText) { _ in
                                viewModel.updateFilteredFragments()
                            }
                        
                        // Filter Segment
                        Picker("ステータス", selection: $viewModel.selectedStatus) {
                            Text("すべて").tag(Optional<FragmentStatus>.none)
                            ForEach(FragmentStatus.allCases, id: \.self) { status in
                                Text(status.displayName).tag(Optional(status))
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, Spacing.md)
                        .onChange(of: viewModel.selectedStatus) { _ in
                            viewModel.updateFilteredFragments()
                        }
                        
                        // Fragment List
                        if viewModel.fragments.isEmpty {
                            EmptyStateView(
                                title: "メモがありません",
                                message: "新しい断片メモを作成してください",
                                actionTitle: "メモを作成",
                                action: { showEditor = true }
                            )
                            .padding(Spacing.lg)
                        } else {
                            VStack(spacing: Spacing.md) {
                                ForEach(viewModel.fragments, id: \.id) { fragment in
                                    NavigationLink(value: fragment) {
                                        FragmentCardView(fragment: fragment)
                                    }
                                    .foregroundColor(Colors.text)
                                }
                            }
                            .padding(Spacing.md)
                        }
                    }
                }
            }
            .navigationDestination(for: Fragment.self) { fragment in
                FragmentDetailView(
                    fragment: fragment,
                    allFragments: viewModel.fragments
                )
            }
            .sheet(isPresented: $showEditor) {
                FragmentEditorView()
                    .presentationDetents([.medium, .large])
                    .onDisappear {
                        viewModel.loadFragments()
                    }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    HomeView()
}
