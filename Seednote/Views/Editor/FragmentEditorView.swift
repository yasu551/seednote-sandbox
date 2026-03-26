import SwiftUI

struct FragmentEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FragmentEditorViewModel

    init(
        fragment: Fragment? = nil,
        onSave: @escaping (Fragment) -> Void = { _ in }
    ) {
        _viewModel = StateObject(
            wrappedValue: FragmentEditorViewModel(
                fragment: fragment,
                onSave: onSave
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    TextField("タイトル（任意）", text: $viewModel.title)
                        .font(Typography.headline)
                        .padding(Spacing.md)
                        .background(Colors.surface)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: Spacing.cornerRadius,
                                style: .continuous
                            )
                        )

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("本文")
                            .font(Typography.subheadline)
                            .foregroundColor(Colors.textSecondary)

                        TextEditor(text: $viewModel.body)
                            .font(Typography.body)
                            .frame(minHeight: 240)
                            .padding(Spacing.sm)
                            .background(Colors.surface)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: Spacing.cornerRadius,
                                    style: .continuous
                                )
                            )
                    }

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("タグ（カンマ区切り）")
                            .font(Typography.subheadline)
                            .foregroundColor(Colors.textSecondary)

                        TextField("例: 発想, 朝, UI", text: $viewModel.tagInput)
                            .font(Typography.body)
                            .padding(Spacing.md)
                            .background(Colors.surface)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: Spacing.cornerRadius,
                                    style: .continuous
                                )
                            )
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

                    VStack(spacing: Spacing.md) {
                        PrimaryButton(
                            title: "保存してAI整理",
                            action: {
                                if viewModel.saveAndAnalyze() != nil {
                                    dismiss()
                                }
                            },
                            disabled: !viewModel.canSave
                        )

                        SecondaryButton(
                            title: "保存",
                            action: {
                                if viewModel.saveFragment() != nil {
                                    dismiss()
                                }
                            },
                            disabled: !viewModel.canSave
                        )

                        SecondaryButton(
                            title: "キャンセル",
                            action: { dismiss() }
                        )
                    }
                    .padding(.top, Spacing.md)
                }
                .padding(Spacing.md)
            }
            .navigationTitle(viewModel.screenTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview("新規作成") {
    FragmentEditorView()
}

#Preview("編集") {
    FragmentEditorView(fragment: PreviewData.processedFragment)
}
