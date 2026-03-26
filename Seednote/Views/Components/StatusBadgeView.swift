import SwiftUI

struct StatusBadgeView: View {
    let status: FragmentStatus
    
    var badgeColor: Color {
        switch status {
        case .unprocessed:
            return Color.gray
        case .growing:
            return Colors.warning
        case .used:
            return Colors.success
        }
    }
    
    var body: some View {
        Text(status.displayName)
            .font(Typography.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(badgeColor)
            .cornerRadius(6)
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
