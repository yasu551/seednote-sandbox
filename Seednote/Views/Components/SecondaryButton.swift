import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var disabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.headline)
                .foregroundColor(Colors.primary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(Colors.surface)
        .cornerRadius(Spacing.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                .stroke(Colors.primary, lineWidth: 1.5)
        )
        .opacity(disabled ? 0.5 : 1.0)
        .disabled(disabled)
        .padding(.horizontal, Spacing.md)
    }
}

#Preview {
    SecondaryButton(title: "キャンセル", action: {})
}
