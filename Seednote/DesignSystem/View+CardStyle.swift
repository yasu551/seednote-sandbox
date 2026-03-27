import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .padding(Spacing.md)
            .background(Colors.surface)
            .cornerRadius(Spacing.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                    .stroke(Colors.divider, lineWidth: Spacing.dividerWidth)
            )
    }
}
