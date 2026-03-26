import SwiftUI
import SwiftData

struct FragmentDetailView: View {
    @State private var fragment: Fragment
    @StateObject private var viewModel: FragmentDetailViewModel
    @State private var showEditor = false
    @State private var selectedTemplate: TemplateType? = nil
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) var dismiss
    
    private let repository: FragmentRepositoryProtocol
    private let allFragments: [Fragment]
    
    init(fragment: Fragment, allFragments: [Fragment]) {
        let repository = SwiftDataFragmentRepository(
            modelContext: AppRouter.shared.modelContainer.mainContext
        )
        self.repository = repository
        self.allFragments = allFragments
        
        _fragment = State(initialValue: fragment)
        _viewModel = StateObject(wrappedValue: FragmentDetailViewModel(
            fragment: fragment,
            repository: repository,
            aiService: AppRouter.shared.aiService,
            relatedService: AppRouter.shared.relatedService,
            allFragments: allFragments
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                    // Original Text Section
                    SectionCardView(title: "原文") {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            if !fragment.title.isEmpty {
                                Text(fragment.title)
                                    .font(Typography.headline)
                            }
                            
                            Text(fragment.body)
                                .font(Typography.body)
                                .lineSpacing(4)
                            
                            if !fragment.tags.isEmpty {
                                Divider()
                                    .padding(.vertical, Spacing.sm)
                                
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    ForEach(fragment.tags, id: \.self) { tag in
                                        TagChipView(tag: tag)
                                    }
                                }
                            }
                        }
                    }
                    .padding(Spacing.md)
                    
                    // AI Analysis Section
                    if let summary = fragment.aiSummary {
                        SectionCardView(title: "AI 整理") {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                if let type = fragment.type {
                                    HStack(spacing: Spacing.md) {
                                        Text("タイプ:")
                                            .font(Typography.subheadline)
                                            .foregroundColor(Colors.textSecondary)
                                        TypeBadgeView(type: type)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text("要約")
                                        .font(Typography.subheadline)
                                        .foregroundColor(Colors.textSecondary)
                                    Text(summary)
                                        .font(Typography.body)
                                }
                                
                                if let question = fragment.aiQuestion {
                                    VStack(alignment: .leading, spacing: Spacing.xs) {
                                        Text("質問")
                                            .font(Typography.subheadline)
                                            .foregroundColor(Colors.textSecondary)
                                        Text(question)
                                            .font(Typography.body)
                                    }
                                }
                                
                                if let claim = fragment.aiClaim {
                                    VStack(alignment: .leading, spacing: Spacing.xs) {
                                        Text("主張")
                                            .font(Typography.subheadline)
                                            .foregroundColor(Colors.textSecondary)
                                        Text(claim)
                                            .font(Typography.body)
                                    }
                                }
                            }
                        }
                        .padding(Spacing.md)
                    }
                    
                    // Related Fragments Section
                    if !viewModel.relatedFragments.isEmpty {
                        SectionCardView(title: "関連断片") {
                            VStack(spacing: Spacing.md) {
                                ForEach(viewModel.relatedFragments, id: \.id) { related in
                                    NavigationLink(value: related.fragment) {
                                        FragmentCardView(fragment: related.fragment)
                                    }
                                    .foregroundColor(Colors.text)
                                }
                            }
                        }
                        .padding(Spacing.md)
                    }
                    
                    // Template Section
                    SectionCardView(title: "再利用テンプレート") {
                        VStack(spacing: Spacing.md) {
                            ForEach(TemplateType.allCases, id: \.self) { template in
                                Button(action: { selectedTemplate = template }) {
                                    HStack {
                                        Text(template.displayName)
                                            .font(Typography.headline)
                                            .foregroundColor(Colors.text)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right")
                                            .foregroundColor(Colors.primary)
                                    }
                                    .padding(Spacing.md)
                                    .background(Colors.background)
                                    .cornerRadius(Spacing.cornerRadius)
                                }
                            }
                        }
                    }
                    .padding(Spacing.md)
            }
        }
        .navigationDestination(for: Fragment.self) { frag in
            FragmentDetailView(fragment: frag, allFragments: allFragments)
        }
        .navigationDestination(isPresented: Binding(
            get: { selectedTemplate != nil },
            set: { if !$0 { selectedTemplate = nil } }
        )) {
            if let template = selectedTemplate {
                GeneratedDraftView(fragment: fragment, template: template)
            }
        }
        .navigationTitle(fragment.title.isEmpty ? "メモ" : fragment.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showEditor = true }) {
                        Label("編集", systemImage: "pencil")
                    }
                    
                    Button(action: { viewModel.reanalyzeFragment() }) {
                        Label("再整理", systemImage: "sparkles")
                    }
                    
                    Button(role: .destructive, action: { showDeleteConfirm = true }) {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            FragmentEditorView(fragment: fragment)
                .presentationDetents([.medium, .large])
        }
        .alert("削除確認", isPresented: $showDeleteConfirm) {
            Button("キャンセル", role: .cancel) { }
            Button(role: .destructive) {
                viewModel.deleteFragment()
                dismiss()
            } label: {
                Text("削除")
            }
        } message: {
            Text("このメモを削除してよろしいですか？")
        }
        .overlay {
            LoadingOverlayView(isShowing: $viewModel.isLoading, message: "AI で再整理中...")
        }
    }
}

#Preview {
    FragmentDetailView(fragment: PreviewData.sampleFragment, allFragments: PreviewData.sampleFragments)
}
