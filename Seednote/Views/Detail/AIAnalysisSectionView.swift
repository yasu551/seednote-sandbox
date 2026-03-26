import SwiftUI

struct AIAnalysisSectionView: View {
    let fragment: Fragment
    let onAnalyze: () -> Void

    init(fragment: Fragment, onAnalyze: @escaping () -> Void) {
        self.fragment = fragment
        self.onAnalyze = onAnalyze
    }

    var body: some View {
        SectionCardView(title: "AI整理") {
            if fragment.aiSummary == nil {
                PrimaryButton(title: "AI整理を実行", action: onAnalyze)
            } else {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    AIAnalysisItemView(title: "要約", content: displayText(fragment.aiSummary))
                    AIAnalysisItemView(title: "問い", content: displayText(fragment.aiQuestion))
                    AIAnalysisItemView(title: "主張", content: displayText(fragment.aiClaim))
                    AIAnalysisItemView(title: "比喩 / イメージ", content: displayText(fragment.aiImage))

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("使い道候補")
                            .font(Typography.subheadline)
                            .foregroundColor(Colors.textSecondary)

                        if fragment.aiUseCases.isEmpty {
                            Text("未設定")
                                .font(Typography.body)
                                .foregroundColor(Colors.text)
                        } else {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                ForEach(fragment.aiUseCases, id: \.self) { useCase in
                                    Text("・\(useCase)")
                                        .font(Typography.body)
                                        .foregroundColor(Colors.text)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func displayText(_ value: String?) -> String {
        guard let value, value.isEmpty == false else {
            return "未設定"
        }
        return value
    }
}

private struct AIAnalysisItemView: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(Typography.subheadline)
                .foregroundColor(Colors.textSecondary)

            Text(content)
                .font(Typography.body)
                .foregroundColor(Colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.md) {
            AIAnalysisSectionView(fragment: PreviewData.unprocessedFragment, onAnalyze: {})
            AIAnalysisSectionView(fragment: PreviewData.processedFragment, onAnalyze: {})
        }
        .padding(Spacing.md)
    }
}
