import SwiftUI

struct FragmentCardView: View {
    let fragment: Fragment

    var displayTitle: String {
        let title = fragment.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !title.isEmpty {
            return title
        }

        return fragment.body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var displaySummary: String? {
        guard let aiSummary = fragment.aiSummary?.trimmingCharacters(in: .whitespacesAndNewlines),
              !aiSummary.isEmpty else {
            return nil
        }

        return aiSummary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(displayTitle)
                    .font(Typography.headline)
                    .foregroundColor(Colors.text)
                    .lineLimit(1)

                if let displaySummary {
                    Text(displaySummary)
                        .font(Typography.footnote)
                        .foregroundColor(Colors.textSecondary)
                        .lineLimit(2)
                }
            }

            HStack(spacing: Spacing.sm) {
                StatusBadgeView(status: fragment.status)
                TypeBadgeView(type: fragment.type)

                Spacer()

                Text(fragment.updatedAt.formattedShort())
                    .font(Typography.caption2)
                    .foregroundColor(Colors.textTertiary)
            }
        }
        .cardStyle()
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        FragmentCardView(fragment: PreviewData.processedFragment)
        FragmentCardView(fragment: PreviewData.unprocessedFragment)
    }
    .padding()
}
