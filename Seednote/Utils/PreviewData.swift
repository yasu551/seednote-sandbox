import Foundation

struct PreviewData {
    static let sampleFragments = [
        Fragment(
            id: UUID(),
            title: "朝日を浴びたときの感覚",
            body: "目を覚ましたとき、カーテンの隙間から入った朝日が顔を優しく撫でた。その瞬間、昨日の疲れがす〜っと引いていくのを感じた。光の温かさって、物理的なものじゃなく、心理的なものなんだろうか。",
            statusRawValue: FragmentStatus.unprocessed.rawValue,
            tags: ["感覚", "朝", "光"],
            aiSummary: nil
        ),
        Fragment(
            id: UUID(),
            title: "アプリのナビゲーション案",
            body: "ユーザーが断片から最終成果物まで、スムーズに移動できるUIを意識したい。下部タブは不要で、NavigationStackで十分。戻るボタンもシンプルに。",
            statusRawValue: FragmentStatus.growing.rawValue,
            typeRawValue: FragmentType.idea.rawValue,
            tags: ["UI", "アプリ開発"],
            aiSummary: "アプリのナビゲーション最適化について"
        ),
        Fragment(
            id: UUID(),
            title: "短編のプロット",
            body: "主人公は町を出たいと思っている。でも家族を置いていくことはできない。その矛盾を解くために...は、新しい形の家族を作ることだ。",
            statusRawValue: FragmentStatus.used.rawValue,
            typeRawValue: FragmentType.claim.rawValue,
            tags: ["小説", "短編"],
            aiSummary: "家族と自由のテーマ"
        ),
    ]
    
    static let sampleFragment = sampleFragments.first ?? Fragment()
}
