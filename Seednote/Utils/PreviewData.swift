import Foundation

struct PreviewData {
    static let unprocessedFragment = Fragment(
        id: UUID(),
        title: "朝日を浴びたときの感覚",
        body: "目を覚ましたとき、カーテンの隙間から入った朝日が顔を優しく撫でた。その瞬間、昨日の疲れがすっと引いていくのを感じた。光の温かさは物理だけではなく、心の受け取り方にも影響している気がする。",
        createdAt: Date(timeIntervalSince1970: 1_710_000_000),
        updatedAt: Date(timeIntervalSince1970: 1_710_000_000),
        statusRawValue: FragmentStatus.unprocessed.rawValue,
        tags: ["感覚", "朝", "光"]
    )

    static let processedFragment = Fragment(
        id: UUID(),
        title: "アプリのナビゲーション案",
        body: "ユーザーが断片から最終成果物まで迷わず移動できる導線にしたい。下部タブは持たず、一覧から詳細、生成結果までをNavigationStack中心でつなぐ構成が良さそう。",
        createdAt: Date(timeIntervalSince1970: 1_710_086_400),
        updatedAt: Date(timeIntervalSince1970: 1_710_090_000),
        statusRawValue: FragmentStatus.growing.rawValue,
        typeRawValue: FragmentType.idea.rawValue,
        tags: ["UI", "アプリ開発"],
        aiSummary: "断片一覧から詳細、ドラフト生成までを一筆書きで移動できる導線案。",
        aiQuestion: "どの画面からでも迷わず一覧に戻れる構造にするには？",
        aiClaim: "下部タブよりNavigationStack中心の遷移の方が体験が軽い。",
        aiUseCases: ["情報設計の叩き台", "画面遷移の検討"]
    )

    static let usedFragment = Fragment(
        id: UUID(),
        title: "短編のプロット",
        body: "主人公は町を出たいと思っている。でも家族を置いていくことはできない。その矛盾を解く鍵は、血縁ではなく選び直したつながりを家族として受け入れることにある。",
        createdAt: Date(timeIntervalSince1970: 1_710_172_800),
        updatedAt: Date(timeIntervalSince1970: 1_710_176_400),
        statusRawValue: FragmentStatus.used.rawValue,
        typeRawValue: FragmentType.claim.rawValue,
        tags: ["小説", "短編"],
        aiSummary: "自由と家族責任の対立を、新しい家族像で解決する物語の核。",
        aiClaim: "主人公の成長は『家族を捨てるか守るか』ではなく『家族を再定義できるか』にある。",
        aiUseCases: ["物語のテーマ整理", "プロット骨子"]
    )

    static let sampleFragments = [
        unprocessedFragment,
        processedFragment,
        usedFragment,
    ]
    
    static let sampleFragment = sampleFragments.first ?? Fragment()

    static let sampleDraft = GeneratedDraft(
        fragmentID: processedFragment.id,
        templateRawValue: TemplateType.essayOutline.rawValue,
        content: """
        1. 問題提起
        断片を一覧で持っていても、次の行動が見えないとメモは埋もれていく。

        2. 中心となる主張
        NavigationStack を軸にして、一覧から詳細、詳細からドラフト生成までを素直につなぐ。

        3. 具体例
        断片カードから詳細へ進み、その場で AI 整理結果と生成アクションを見せる。

        4. まとめ
        導線を減らすほど、断片は成果物へ育ちやすくなる。
        """,
        createdAt: Date(timeIntervalSince1970: 1_710_093_600)
    )
}
