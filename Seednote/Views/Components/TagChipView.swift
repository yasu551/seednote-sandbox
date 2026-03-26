import SwiftUI

struct TagChipView: View {
    let tag: String
    var isRemovable: Bool = false
    var onRemove: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text(tag)
                .font(Typography.caption1)
                .foregroundColor(Colors.text)
            
            if isRemovable {
                Button(action: { onRemove?() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(Colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Colors.surface)
        .overlay {
            Capsule()
                .stroke(Colors.divider, lineWidth: 0.8)
        }
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        HStack(spacing: Spacing.sm) {
            TagChipView(tag: "質問")
            TagChipView(tag: "観察", isRemovable: true, onRemove: {})
            Spacer()
        }
    }
    .padding()
}
