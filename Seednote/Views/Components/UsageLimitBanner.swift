import SwiftUI

struct UsageLimitBanner: View {
    let title: String
    let message: String
    
    init(title: String, message: String) {
        self.title = title
        self.message = message
    }
    
    init(remaining: Int, type: String) {
        self.title = "AI\(type)の残りは \(remaining) 回です"
        self.message = "必要に応じて使用回数を確認してください。"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: "exclamationmark.circle")
                .foregroundColor(Colors.warning)
                .font(.system(size: 18, weight: .medium))
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(Typography.subheadline)
                    .foregroundColor(Colors.text)
                
                Text(message)
                    .font(Typography.caption1)
                    .foregroundColor(Colors.textSecondary)
            }
            
            Spacer(minLength: 0)
        }
        .padding(Spacing.md)
        .background(Colors.warning.opacity(0.10))
        .overlay {
            RoundedRectangle(cornerRadius: Spacing.cornerRadius, style: .continuous)
                .stroke(Colors.warning.opacity(0.35), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: Spacing.cornerRadius, style: .continuous))
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        UsageLimitBanner(
            title: "AI整理の上限に近づいています",
            message: "今月の残り回数を確認してください。"
        )
        UsageLimitBanner(remaining: 2, type: "整理")
    }
    .padding()
}
