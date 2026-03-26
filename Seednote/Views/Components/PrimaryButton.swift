import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var disabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(title)
                    .font(Typography.headline)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(Colors.primary)
        .cornerRadius(Spacing.cornerRadius)
        .opacity(disabled ? 0.5 : 1.0)
        .disabled(disabled || isLoading)
        .padding(.horizontal, Spacing.md)
    }
}

#Preview {
    PrimaryButton(title: "保存する", action: {})
}
