import Foundation

class MockAIAnalysisService: AIAnalysisServiceProtocol {
    func analyze(fragmentText: String) async throws -> AIAnalysisResponse {
        try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
        
        let types: [FragmentType] = [.question, .claim, .idea, .world, .observation]
        let randomType = types.randomElement() ?? .idea
        
        return AIAnalysisResponse(
            summary: "「\(fragmentText.prefix(30))...」は、日常の中の重要な気づきを表現しています。",
            type: randomType,
            question: "この経験から何を学べるか？",
            claim: "私たちは日々の瞬間を大切にすべきだ。",
            image: "📝",
            useCases: ["エッセイとして展開", "短編の題材に", "ブログ記事のネタに"]
        )
    }
    
    func generateDraft(fragmentText: String, template: TemplateType) async throws -> DraftGenerationResponse {
        try await Task.sleep(nanoseconds: UInt64(0.8 * Double(NSEC_PER_SEC)))
        
        let draftContent: String
        switch template {
        case .essayOutline:
            draftContent = """
            # エッセイ骨子

            ## はじめに
            「\(fragmentText.prefix(50))」という経験から、以下のことを考えた。

            ## 第1章: 背景
            このテーマについて、一般的には〜という見方がある。

            ## 第2章: 主張
            しかし、本当は〜ではないだろうか。

            ## 第3章: 結論
            つまり、私たちは〜するべきだ。
            """
        case .shortStoryCore:
            draftContent = """
            # 短編の核

            ## 主人公
            日常に違和感を感じている人物

            ## 設定
            「\(fragmentText)」という状況

            ## 転機
            予期しない出来事により、主人公の視点が変わる。

            ## クライマックス
            主人公は新しい選択をする。

            ## エンディング
            その選択がもたらした変化
            """
        case .appIdea:
            draftContent = """
            # アプリ案

            ## 概要
            「\(fragmentText.prefix(30))」をテーマにしたアプリ

            ## ユースケース
            - ユーザーが日々の気づきを記録
            - AIが自動分類・要約
            - 過去の記録から創作を生成

            ## 主な機能
            1. 断片メモ保存
            2. AIによる自動整理
            3. テンプレートに基づく再利用

            ## ビジネスモデル
            基本無料、AI機能数回は無料、以降はサブスク
            """
        }
        
        return DraftGenerationResponse(content: draftContent)
    }
}
