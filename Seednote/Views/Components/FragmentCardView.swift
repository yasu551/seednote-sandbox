import SwiftUI

struct FragmentCardView: View {
    let fragment: Fragment
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    if !fragment.title.isEmpty {
                        Text(fragment.title)
                            .font(Typography.headline)
                            .lineLimit(1)
                    }
                    
                    Text(fragment.body)
                        .font(Typography.footnote)
                        .foregroundColor(Colors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            HStack(spacing: Spacing.sm) {
                StatusBadgeView(status: fragment.status)
                TypeBadgeView(type: fragment.type)
                
                Spacer()
                
                Text(fragment.createdAt.formattedShort())
                    .font(Typography.caption2)
                    .foregroundColor(Colors.textTertiary)
            }
        }
        .cardStyle()
    }
}

#Preview {
    FragmentCardView(fragment: PreviewData.sampleFragment)
        .padding()
}
