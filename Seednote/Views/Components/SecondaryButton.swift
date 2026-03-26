import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var disabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.headline)
                .foregroundColor(Colors.text)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Colors.background)
                .overlay {
                    RoundedRectangle(cornerRadius: Spacing.cornerRadius, style: .continuous)
                        .stroke(Colors.divider, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: Spacing.cornerRadius, style: .continuous))
        }
        .opacity(disabled ? 0.5 : 1.0)
        .disabled(disabled)
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.md)
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        SecondaryButton(title: "キャンセル", action: {})
        SecondaryButton(title: "キャンセル", action: {}, disabled: true)
    }
}
