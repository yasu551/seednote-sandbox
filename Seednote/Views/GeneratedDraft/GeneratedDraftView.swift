import SwiftUI

struct GeneratedDraftView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: GeneratedDraftViewModel

    private let fragment: Fragment

    init(fragment: Fragment, template: TemplateType) {
        self.fragment = fragment

        _viewModel = StateObject(wrappedValue: GeneratedDraftViewModel(
            fragment: fragment,
            template: template,
            aiService: AppRouter.shared.aiService,
            repository: AppRouter.shared.repository,
            usageLimit: AppRouter.shared.usageLimitService
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                SectionCardView(title: "もとの断片") {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        if !fragment.title.isEmpty {
                            Text(fragment.title)
                                .font(Typography.headline)
                                .foregroundColor(Colors.text)
                        }

                        Text(fragment.body)
                            .font(Typography.body)
                            .foregroundColor(Colors.text)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                SectionCardView(title: "生成結果") {
                    VStack(spacing: Spacing.md) {
                        TextEditor(text: $viewModel.draftContent)
                            .font(Typography.body)
                            .frame(minHeight: 320)
                            .padding(Spacing.sm)
                            .background(Colors.surface)
                            .cornerRadius(Spacing.cornerRadius)

                        VStack(spacing: Spacing.md) {
                            PrimaryButton(
                                title: "新規メモとして保存",
                                action: {
                                    if viewModel.saveAsNewFragment() {
                                        dismiss()
                                    }
                                },
                                disabled: viewModel.draftContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            )

                            SecondaryButton(
                                title: "コピー",
                                action: {
                                    viewModel.copyToClipboard()
                                },
                                disabled: viewModel.draftContent.isEmpty
                            )
                        }
                    }
                }
            }
            .padding(Spacing.md)
        }
        .navigationTitle(viewModel.draft.template?.displayName ?? "生成結果")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.draftContent.isEmpty {
                await viewModel.generateDraft()
            }
        }
        .overlay(
            LoadingOverlayView(isShowing: $viewModel.isLoading, message: "生成中...")
        )
    }
}

#Preview {
    NavigationStack {
        GeneratedDraftView(fragment: PreviewData.sampleFragment, template: .essayOutline)
    }
}
