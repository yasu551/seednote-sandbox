import SwiftUI

struct TypeBadgeView: View {
    private let type: FragmentType?
    
    init(type: FragmentType) {
        self.type = type
    }
    
    init(type: FragmentType?) {
        self.type = type
    }
    
    private var badgeStyle: (background: Color, foreground: Color) {
        guard let type else {
            return (Colors.textSecondary.opacity(0.12), Colors.textSecondary)
        }
        
        switch type {
        case .question:
            return (Colors.primary.opacity(0.14), Colors.text)
        case .claim:
            return (Colors.secondary.opacity(0.14), Colors.text)
        case .idea:
            return (Colors.success.opacity(0.14), Colors.text)
        case .world:
            return (Colors.warning.opacity(0.18), Colors.text)
        case .observation:
            return (Colors.textSecondary.opacity(0.12), Colors.text)
        }
    }
    
    var body: some View {
        if let type = type {
            Text(type.displayName)
                .font(Typography.caption1)
                .foregroundColor(badgeStyle.foreground)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(badgeStyle.background)
                .overlay {
                    Capsule()
                        .stroke(badgeStyle.background.opacity(0.9), lineWidth: 1)
                }
                .clipShape(Capsule())
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
