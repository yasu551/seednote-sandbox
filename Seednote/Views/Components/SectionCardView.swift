import SwiftUI

struct SectionCardView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(Typography.headline)
                .foregroundColor(Colors.text)
            
            content
        }
        .cardStyle()
    }
}

#Preview {
    SectionCardView(title: "テストセクション") {
        Text("コンテンツがここに入ります")
            .font(Typography.body)
    }
    .padding()
}
