import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    init() {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            subscriptionService: AppRouter.shared.subscriptionService,
            usageLimitService: AppRouter.shared.usageLimitService
        ))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Subscription Status
                    SectionCardView(title: "プラン") {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            HStack {
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text(viewModel.subscriptionTier == .free ? "Free" : "Pro")
                                        .font(Typography.headline)
                                        .fontWeight(.bold)
                                    
                                    Text(viewModel.subscriptionTier == .free ? "無料プラン" : "プレミアムプラン")
                                        .font(Typography.caption1)
                                        .foregroundColor(Colors.textSecondary)
                                }
                                
                                Spacer()
                                
                                if viewModel.subscriptionTier == .free {
                                    Button(action: {}) {
                                        Text("Pro に加入")
                                            .font(Typography.caption1)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, Spacing.md)
                                            .padding(.vertical, Spacing.sm)
                                            .background(Colors.primary)
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }
                    }
                    .padding(Spacing.md)
                    
                    // Usage Limits
                    SectionCardView(title: "今月の使用状況") {
                        VStack(spacing: Spacing.md) {
                            HStack {
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text("AI 整理")
                                        .font(Typography.subheadline)
                                    
                                    ProgressView(
                                        value: Double(10 - viewModel.analysisRemaining),
                                        total: 10
                                    )
                                    .tint(Colors.primary)
                                    
                                    Text("残り: \(viewModel.analysisRemaining) 回")
                                        .font(Typography.caption2)
                                        .foregroundColor(Colors.textSecondary)
                                }
                                
                                Spacer()
                            }
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text("再利用生成")
                                        .font(Typography.subheadline)
                                    
                                    ProgressView(
                                        value: Double(5 - viewModel.templateRemaining),
                                        total: 5
                                    )
                                    .tint(Colors.success)
                                    
                                    Text("残り: \(viewModel.templateRemaining) 回")
                                        .font(Typography.caption2)
                                        .foregroundColor(Colors.textSecondary)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(Spacing.md)
                    
                    // Links
                    SectionCardView(title: "サポート") {
                        VStack(spacing: Spacing.md) {
                            Button(action: {}) {
                                HStack {
                                    Text("利用規約")
                                        .foregroundColor(Colors.text)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .foregroundColor(Colors.primary)
                                }
                            }
                            
                            Divider()
                            
                            Button(action: {}) {
                                HStack {
                                    Text("プライバシーポリシー")
                                        .foregroundColor(Colors.text)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .foregroundColor(Colors.primary)
                                }
                            }
                            
                            Divider()
                            
                            Button(action: {}) {
                                HStack {
                                    Text("お問い合わせ")
                                        .foregroundColor(Colors.text)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .foregroundColor(Colors.primary)
                                }
                            }
                        }
                    }
                    .padding(Spacing.md)
                    
                    // Version
                    VStack(spacing: Spacing.sm) {
                        Text("Seednote")
                            .font(Typography.subheadline)
                            .fontWeight(.semibold)
                        Text("v1.0.0 (MVP)")
                            .font(Typography.caption2)
                            .foregroundColor(Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.lg)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる", action: { dismiss() })
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
