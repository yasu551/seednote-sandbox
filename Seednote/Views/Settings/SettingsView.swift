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
                    SectionCardView(title: "現在のプラン") {
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
                                    PrimaryButton(title: "Pro を購入") {
                                        Task {
                                            await viewModel.purchasePro()
                                        }
                                    }
                                }
                            }

                            SecondaryButton(title: "購入を復元") {
                                Task {
                                    await viewModel.restorePurchases()
                                }
                            }
                        }
                    }
                    .padding(Spacing.md)

                    SectionCardView(title: "利用回数") {
                        VStack(spacing: Spacing.md) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("AI整理の残回数")
                                    .font(Typography.subheadline)
                                Spacer()
                                Text("\(viewModel.analysisRemaining) 回")
                                    .font(Typography.subheadline)
                                    .fontWeight(.semibold)
                            }

                            Divider()

                            HStack(alignment: .firstTextBaseline) {
                                Text("再利用の残回数")
                                    .font(Typography.subheadline)
                                Spacer()
                                Text("\(viewModel.templateRemaining) 回")
                                    .font(Typography.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding(Spacing.md)

                    SectionCardView(title: "サポート") {
                        VStack(spacing: Spacing.md) {
                            Button(action: {}) {
                                HStack {
                                    Text("規約")
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
