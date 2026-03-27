import SwiftUI
import SwiftData

struct FragmentEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: FragmentEditorViewModel
    @State private var errorMessage: String?

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
                                Task {
                                    await persistAndAnalyze()
                                }
                            },
                            isLoading: viewModel.isLoading,
                            disabled: !viewModel.canSave || viewModel.isLoading
                        )

                        SecondaryButton(
                            title: "保存",
                            action: {
                                persist(viewModel.saveFragment())
                            },
                            disabled: !viewModel.canSave || viewModel.isLoading
                        )

                        SecondaryButton(
                            title: "キャンセル",
                            action: { dismiss() },
                            disabled: viewModel.isLoading
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
                    .disabled(viewModel.isLoading)
                }
            }
            .alert("エラー", isPresented: isShowingError) {
                Button("閉じる", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func persist(_ fragment: Fragment?) {
        guard let fragment else {
            return
        }

        let repository = FragmentRepository.make(modelContext: modelContext)

        do {
            if viewModel.shouldUpdatePersistedFragment {
                try repository.update(fragment)
            } else {
                try repository.save(fragment)
                viewModel.markAsPersisted()
            }
            dismiss()
        } catch {
            errorMessage = "保存に失敗しました"
            print("Failed to persist fragment: \(error)")
        }
    }

    private func persistAndAnalyze() async {
        guard let fragment = viewModel.saveFragment() else {
            return
        }

        let repository = FragmentRepository.make(modelContext: modelContext)

        do {
            if viewModel.shouldUpdatePersistedFragment {
                try repository.update(fragment)
            } else {
                try repository.save(fragment)
                viewModel.markAsPersisted()
            }
        } catch {
            errorMessage = "保存に失敗しました"
            print("Failed to persist fragment before analyze: \(error)")
            return
        }

        do {
            try await viewModel.analyzeFragment(fragment)
            if let usageLimitMessage = viewModel.usageLimitMessage {
                errorMessage = usageLimitMessage
                viewModel.usageLimitMessage = nil
                return
            }
            try repository.update(fragment)
            dismiss()
        } catch {
            errorMessage = "AI整理に失敗しました"
            print("Failed to analyze fragment: \(error)")
        }
    }

    private var isShowingError: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )
    }
}

#Preview("新規作成") {
    FragmentEditorView()
        .modelContainer(for: Fragment.self, inMemory: true)
}

#Preview("編集") {
    FragmentEditorView(fragment: PreviewData.processedFragment)
        .modelContainer(for: Fragment.self, inMemory: true)
}

#Preview("新規作成") {
    FragmentEditorView()
        .modelContainer(makeEditorPreviewContainer())
}

#Preview("編集") {
    FragmentEditorView(fragment: PreviewData.processedFragment)
        .modelContainer(makeEditorPreviewContainer())
}

@MainActor
private func makeEditorPreviewContainer() -> ModelContainer {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    return try! ModelContainer(
        for: Fragment.self,
        GeneratedDraft.self,
        configurations: configuration
    )
}
