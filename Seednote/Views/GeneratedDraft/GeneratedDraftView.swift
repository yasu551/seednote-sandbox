import SwiftUI
import SwiftData

struct GeneratedDraftView: View {
    @StateObject private var viewModel: GeneratedDraftViewModel
    @State private var editedContent: String = ""
    @State private var showSaveAlert = false
    @Environment(\.dismiss) var dismiss
    
    private let fragment: Fragment
    private let template: TemplateType
    private let repository: FragmentRepositoryProtocol
    
    init(fragment: Fragment, template: TemplateType) {
        self.fragment = fragment
        self.template = template
        
        let repository = SwiftDataFragmentRepository(
            modelContext: AppRouter.shared.modelContainer.mainContext
        )
        self.repository = repository
        
        _viewModel = StateObject(wrappedValue: GeneratedDraftViewModel(
            fragment: fragment,
            template: template,
            aiService: AppRouter.shared.aiService,
            repository: repository,
            usageLimit: AppRouter.shared.usageLimitService
        ))
        
        _editedContent = State(initialValue: "")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    // Header
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text(template.displayName)
                            .font(Typography.title2)
                            .fontWeight(.bold)
                        
                        Text("「\(fragment.title.isEmpty ? fragment.body.prefix(30) : fragment.title)...」から生成")
                            .font(Typography.caption1)
                            .foregroundColor(Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.md)
                    
                    // Content Editor
                    TextEditor(text: $editedContent)
                        .font(Typography.body)
                        .frame(minHeight: 300)
                        .padding(Spacing.md)
                        .background(Colors.surface)
                        .cornerRadius(Spacing.cornerRadius)
                        .padding(Spacing.md)
                        .onAppear {
                            editedContent = viewModel.draftContent
                        }
                        .onChange(of: viewModel.draftContent) { newValue in
                            if editedContent.isEmpty {
                                editedContent = newValue
                            }
                        }
                    
                    // Action Buttons
                    VStack(spacing: Spacing.md) {
                        PrimaryButton(
                            title: "コピー",
                            action: {
                                viewModel.draftContent = editedContent
                                viewModel.copyToClipboard()
                            }
                        )
                        
                        SecondaryButton(
                            title: "新規メモとして保存",
                            action: {
                                viewModel.draftContent = editedContent
                                viewModel.saveAsNewFragment()
                                showSaveAlert = true
                            }
                        )
                        
                        SecondaryButton(
                            title: "戻る",
                            action: { dismiss() }
                        )
                    }
                    .padding(.bottom, Spacing.md)
                }
            }
            .navigationTitle("ドラフト")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                LoadingOverlayView(isShowing: $viewModel.isLoading, message: "生成中...")
            )
            .alert("保存完了", isPresented: $showSaveAlert) {
                Button("了解") {
                    dismiss()
                }
            } message: {
                Text("新しいメモとして保存しました")
            }
        }
    }
}

#Preview {
    GeneratedDraftView(fragment: PreviewData.sampleFragment, template: .essayOutline)
}
