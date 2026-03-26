import SwiftUI

struct LoadingOverlayView: View {
    @Binding var isShowing: Bool
    let message: String
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.md) {
                    ProgressView()
                        .tint(Colors.primary)
                    
                    Text(message)
                        .font(Typography.body)
                        .foregroundColor(Colors.text)
                }
                .frame(maxWidth: 240)
                .cardStyle()
                .padding(Spacing.lg)
            }
        }
    }
}

#Preview {
    LoadingOverlayPreview()
}

private struct LoadingOverlayPreview: View {
    @State private var isShowing = true
    
    var body: some View {
        ZStack {
            Colors.background
            LoadingOverlayView(isShowing: $isShowing, message: "AI で整理中...")
        }
    }
}
