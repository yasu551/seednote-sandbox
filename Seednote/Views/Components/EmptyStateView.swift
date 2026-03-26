import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String = "📝",
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
        VStack(spacing: Spacing.lg) {
            Text(icon)
                .font(.system(size: 64))
            
            Text(title)
                .font(Typography.title2)
                .foregroundColor(Colors.text)
            
            Text(message)
                .font(Typography.body)
                .foregroundColor(Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.top, Spacing.md)
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(
        title: "メモがありません",
        message: "新しい断片メモを作成してください",
        actionTitle: "メモを作成",
        action: {}
    )
}
