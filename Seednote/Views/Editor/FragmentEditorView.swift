import SwiftUI
import SwiftData

struct FragmentEditorView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: FragmentEditorViewModel
    @State private var tagInput: String = ""
    
    private let repository: FragmentRepositoryProtocol
    private let aiService: AIAnalysisServiceProtocol
    private let usageLimit: UsageLimitService
    
    init(fragment: Fragment? = nil) {
        let repository = SwiftDataFragmentRepository(
            modelContext: ModelContext(AppRouter.shared.modelContainer)
        )
        self.repository = repository
        self.aiService = AppRouter.shared.aiService
        self.usageLimit = AppRouter.shared.usageLimitService
        
        _viewModel = State(initialValue: FragmentEditorViewModel(
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
                    TextField("タイトル (オプション)", text: $viewModel.fragment.title)
                        .font(Typography.headline)
                        .padding(Spacing.md)
                        .background(Colors.surface)
                        .cornerRadius(Spacing.cornerRadius)
                        .padding(Spacing.md)
                    
                    // Body Input
                    TextEditor(text: $viewModel.fragment.body)
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
                        
                        TextField("例: 感覚, 朝, 光", text: $tagInput)
                            .font(Typography.body)
                            .padding(Spacing.md)
                            .background(Colors.surface)
                            .cornerRadius(Spacing.cornerRadius)
                            .onChange(of: tagInput) { newValue in
                                viewModel.fragment.tags = newValue.tagsFromCommaSeparated()
                            }
                        
                        if !viewModel.fragment.tags.isEmpty {
                            FlowLayout(spacing: Spacing.sm) {
                                ForEach(viewModel.fragment.tags, id: \.self) { tag in
                                    TagChipView(tag: tag)
                                }
                            }
                        }
                    }
                    .padding(Spacing.md)
                    
                    Spacer()
                    
                    // Usage Limit Banner
                    if viewModel.fragment.aiSummary == nil {
                        UsageLimitBanner(remaining: usageLimit.analysisRemaining(), type: "整理")
                            .padding(Spacing.md)
                    }
                    
                    // Buttons
                    VStack(spacing: Spacing.md) {
                        PrimaryButton(
                            title: "保存してAI整理",
                            action: { viewModel.saveAndAnalyze() },
                            isLoading: viewModel.isLoading,
                            disabled: viewModel.fragment.body.isEmpty
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
            .overlay(
                LoadingOverlayView(isShowing: $viewModel.isLoading, message: "AI で整理中...")
            )
            .alert("エラー", isPresented: $viewModel.showError) {
                Button("了解") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? .infinity, subviews: subviews, spacing: spacing)
        return result.size
                            }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: result.frames[index].origin,
                proposal: ProposedSize(result.frames[index].size)
            )
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var lineWidth: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > width && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                    lineWidth = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                currentX += size.width + spacing
                lineWidth = currentX
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: width, height: currentY + lineHeight)
        }
    }
}

#Preview {
    FragmentEditorView()
}
