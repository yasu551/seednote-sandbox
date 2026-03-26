import SwiftUI

struct FragmentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FragmentDetailViewModel
    @State private var showEditor = false
    @State private var showDeleteConfirm = false

    init(fragment: Fragment) {
        _viewModel = StateObject(
            wrappedValue: FragmentDetailViewModel(
                fragment: fragment,
                repository: AppRouter.shared.repository,
                aiService: AppRouter.shared.aiService,
                relatedService: AppRouter.shared.relatedService,
                allFragments: []
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                SectionCardView(title: "原文") {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        if !viewModel.fragment.title.isEmpty {
                            Text(viewModel.fragment.title)
                                .font(Typography.headline)
                                .foregroundColor(Colors.text)
                        }

                        Text(viewModel.fragment.body)
                            .font(Typography.body)
                            .foregroundColor(Colors.text)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: Spacing.sm) {
                            StatusBadgeView(status: viewModel.fragment.status)
                            TypeBadgeView(type: viewModel.fragment.type)
                            Spacer()
                        }

                        if !viewModel.fragment.tags.isEmpty {
                            FlowLayout(spacing: Spacing.sm) {
                                ForEach(viewModel.fragment.tags, id: \.self) { tag in
                                    TagChipView(tag: tag)
                                }
                            }
                        }

                        Text(viewModel.displayDateText)
                            .font(Typography.caption2)
                            .foregroundColor(Colors.textTertiary)
                    }
                }

                AIAnalysisSectionView(fragment: viewModel.fragment) {
                    Task {
                        await viewModel.reanalyzeFragment()
                    }
                }
            }
            .padding(Spacing.md)
        }
        .navigationTitle(viewModel.fragment.title.isEmpty ? "メモ" : viewModel.fragment.title)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            LoadingOverlayView(isShowing: $viewModel.isLoading, message: "AIで整理中...")
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if viewModel.fragment.aiSummary != nil {
                        Button {
                            Task {
                                await viewModel.reanalyzeFragment()
                            }
                        } label: {
                            Label("再整理", systemImage: "sparkles")
                        }
                    }

                    Button {
                        showEditor = true
                    } label: {
                        Label("編集", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            FragmentEditorView(fragment: viewModel.fragment) { fragment in
                viewModel.applyEditedFragment(fragment)
            }
            .presentationDetents([.medium, .large])
        }
        .alert("削除確認", isPresented: $showDeleteConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                if viewModel.deleteFragment() {
                    dismiss()
                }
            }
        } message: {
            Text("この断片を削除してよろしいですか？")
        }
    }
}

#Preview {
    NavigationStack {
        FragmentDetailView(fragment: PreviewData.sampleFragment)
    }
}
