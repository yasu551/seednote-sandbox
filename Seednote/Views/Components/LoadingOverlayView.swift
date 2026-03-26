import SwiftUI

struct LoadingOverlayView: View {
    @Binding var isShowing: Bool
    let message: String
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.md) {
                    ProgressView()
                        .tint(Colors.primary)
                    
                    Text(message)
                        .font(Typography.body)
                        .foregroundColor(Colors.text)
                }
                .padding(Spacing.lg)
                .background(Colors.surface)
                .cornerRadius(Spacing.cornerRadius)
            }
        }
    }
}

#Preview {
    @State var isShowing = true
    return LoadingOverlayView(isShowing: $isShowing, message: "AI で整理中...")
}
