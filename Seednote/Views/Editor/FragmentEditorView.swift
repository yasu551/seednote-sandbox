import SwiftUI
import SwiftData

struct FragmentEditorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: FragmentEditorViewModel
    
    private let usageLimit: UsageLimitService
    
    init(fragment: Fragment? = nil) {
        let repository = SwiftDataFragmentRepository(
            modelContext: AppRouter.shared.modelContainer.mainContext
        )
        let aiService = AppRouter.shared.aiService
        let usageLimit = AppRouter.shared.usageLimitService
        self.usageLimit = usageLimit
        
        _viewModel = StateObject(wrappedValue: FragmentEditorViewModel(
            fragment: fragment,
            repository: repository,
            aiService: aiService,
            usageLimit: usageLimit
        ))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    // Title Input
                    TextField("タイトル (オプション)", text: $viewModel.title)
                        .font(Typography.headline)
                        .padding(Spacing.md)
                        .background(Colors.surface)
                        .cornerRadius(Spacing.cornerRadius)
                        .padding(Spacing.md)
                    
                    // Body Input
                    TextEditor(text: $viewModel.body)
                        .font(Typography.body)
                        .frame(minHeight: 200)
                        .padding(Spacing.md)
                        .background(Colors.surface)
                        .cornerRadius(Spacing.cornerRadius)
                        .padding(Spacing.md)
                    
                    // Tags Input
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("タグ (カンマ区切り)")
                            .font(Typography.subheadline)
                            .foregroundColor(Colors.textSecondary)
                        
                        TextField("例: 感覚, 朝, 光", text: $viewModel.tagInput)
                            .font(Typography.body)
                            .padding(Spacing.md)
                            .background(Colors.surface)
                            .cornerRadius(Spacing.cornerRadius)
                            .onChange(of: viewModel.tagInput) { _, newValue in
                                viewModel.tags = newValue.tagsFromCommaSeparated()
                            }
                        
                        if !viewModel.tags.isEmpty {
                            FlowLayout(spacing: Spacing.sm) {
                                ForEach(viewModel.tags, id: \.self) { tag in
                                    TagChipView(tag: tag)
                                }
                            }
                        }
                    }
                    .padding(Spacing.md)
                    
                    Spacer()
                    
                    // Usage Limit Banner
                    if !viewModel.hasAISummary {
                        UsageLimitBanner(remaining: usageLimit.analysisRemaining(), type: "整理")
                            .padding(Spacing.md)
                    }
                    
                    // Buttons
                    VStack(spacing: Spacing.md) {
                        PrimaryButton(
                            title: "保存してAI整理",
                            action: {
                                viewModel.saveAndAnalyze {
                                    dismiss()
                                }
                            },
                            isLoading: viewModel.isLoading,
                            disabled: viewModel.body.isEmpty
                        )
                        
                        SecondaryButton(
                            title: "保存",
                            action: {
                                viewModel.saveFragment()
                                dismiss()
                            }
                        )
                        
                        SecondaryButton(
                            title: "キャンセル",
                            action: { dismiss() }
                        )
                    }
                    .padding(.bottom, Spacing.md)
                }
            }
            .navigationTitle("新規メモ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル", action: { dismiss() })
                }
            }
            .overlay {
                LoadingOverlayView(isShowing: $viewModel.isLoading, message: "AI で整理中...")
            }
            .alert("エラー", isPresented: $viewModel.showError) {
                Button("了解") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    FragmentEditorView()
}
