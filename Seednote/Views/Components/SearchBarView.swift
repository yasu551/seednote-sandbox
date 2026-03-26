import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    let placeholder: String
    
    init(text: Binding<String>, placeholder: String = "検索") {
        _text = text
        self.placeholder = placeholder
    }
    
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
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 12)
        .background(Colors.surface)
        .overlay {
            RoundedRectangle(cornerRadius: Spacing.cornerRadius, style: .continuous)
                .stroke(Colors.divider, lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: Spacing.cornerRadius, style: .continuous))
    }
}

#Preview {
    SearchBarPreview()
        .padding()
}

private struct SearchBarPreview: View {
    @State private var text = "朝のメモ"
    
    var body: some View {
        SearchBarView(text: $text, placeholder: "検索...")
    }
}
