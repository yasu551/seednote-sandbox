import SwiftUI

struct TypeBadgeView: View {
    let type: FragmentType?
    
    var badgeColor: Color {
        guard let type = type else { return .gray }
        return Colors.primary
    }
    
    var body: some View {
        if let type = type {
            Text(type.displayName)
                .font(Typography.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(badgeColor)
                .cornerRadius(6)
        }
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        TypeBadgeView(type: .question)
        TypeBadgeView(type: .claim)
        TypeBadgeView(type: .idea)
    }
    .padding()
}
