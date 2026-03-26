import SwiftUI

struct UsageLimitBanner: View {
    let remaining: Int
    let type: String
    
    var body: some View {
        if remaining < 3 {
            HStack(spacing: Spacing.md) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(Colors.warning)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("AI\(type)の残数:\(remaining)回")
                        .font(Typography.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Pro に加入して無制限に")
                        .font(Typography.caption1)
                        .foregroundColor(Colors.textSecondary)
                }
                
                Spacer()
            }
            .padding(Spacing.md)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(Spacing.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                    .stroke(Colors.warning, lineWidth: 1)
            )
        }
    }
}

#Preview {
    UsageLimitBanner(remaining: 2, type: "整理")
        .padding()
}
