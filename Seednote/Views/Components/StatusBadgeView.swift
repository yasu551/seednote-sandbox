import SwiftUI

struct StatusBadgeView: View {
    let status: FragmentStatus
    
    private var badgeStyle: (background: Color, foreground: Color) {
        switch status {
        case .unprocessed:
            return (Colors.textSecondary.opacity(0.12), Colors.textSecondary)
        case .growing:
            return (Colors.warning.opacity(0.18), Colors.text)
        case .used:
            return (Colors.success.opacity(0.18), Colors.text)
        }
    }
    
    var body: some View {
        Text(status.displayName)
            .font(Typography.caption1)
            .foregroundColor(badgeStyle.foreground)
            .padding(.horizontal, Spacing.badgePaddingH)
            .padding(.vertical, Spacing.badgePaddingV)
            .background(badgeStyle.background)
            .overlay {
                Capsule()
                    .stroke(badgeStyle.background.opacity(0.9), lineWidth: Spacing.borderWidth)
            }
            .clipShape(Capsule())
    }
}

#Preview {
    HStack(spacing: Spacing.md) {
        StatusBadgeView(status: .unprocessed)
        StatusBadgeView(status: .growing)
        StatusBadgeView(status: .used)
    }
    .padding()
}
