import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var disabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(Typography.headline)
                    .foregroundColor(.white)
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.cornerRadius, style: .continuous))
        }
        .opacity(disabled ? 0.5 : 1.0)
        .disabled(disabled || isLoading)
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.md)
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        PrimaryButton(title: "保存する", action: {})
        PrimaryButton(title: "保存する", action: {}, disabled: true)
        PrimaryButton(title: "保存する", action: {}, isLoading: true)
    }
}
