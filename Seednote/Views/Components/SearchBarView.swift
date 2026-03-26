import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Colors.textSecondary)
            
            TextField(placeholder, text: $text)
                .font(Typography.body)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Colors.textSecondary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Colors.surface)
        .cornerRadius(Spacing.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                .stroke(Colors.divider, lineWidth: 0.5)
        )
    }
}

#Preview {
    @State var text = ""
    return SearchBarView(text: $text, placeholder: "検索...")
        .padding()
}
