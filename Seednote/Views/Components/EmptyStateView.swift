import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String = "tray",
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .regular))
                .foregroundColor(Colors.textSecondary)
                .frame(width: 64, height: 64)
                .background(Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: Spacing.cornerRadius, style: .continuous))
            
            Text(title)
                .font(Typography.title3)
                .foregroundColor(Colors.text)
            
            Text(message)
                .font(Typography.footnote)
                .foregroundColor(Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.top, Spacing.sm)
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "tray",
        title: "メモがありません",
        message: "新しい断片メモを作成してください",
        actionTitle: "メモを作成",
        action: {}
    )
}
