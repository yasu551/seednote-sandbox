import SwiftUI

struct TagChipView: View {
    let tag: String
    var isRemovable: Bool = false
    var onRemove: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text(tag)
                .font(Typography.caption1)
            
            if isRemovable {
                Button(action: { onRemove?() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(Colors.surface)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Colors.divider, lineWidth: 0.5)
        )
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
