# CLAUDE.md

## プロジェクト概要

**Seednote** は、思考の断片（Fragment）を記録し、AIが分析・関連付け・下書き生成を行うiOSメモアプリ。

- **対象OS:** iOS 17.0+
- **言語:** Swift 5.9 / SwiftUI / SwiftData
- **外部依存:** なし（Apple フレームワークのみ）
- **UI言語:** 日本語

## ビルド・実行

プロジェクトは XcodeGen で管理されている（`project.yml`）。

```bash
# プロジェクト生成
xcodegen generate
```

XcodeBuildMCP ツールを使ってビルド・テストを行う:

```
# セッションのデフォルト設定を確認
mcp__XcodeBuildMCP__session_show_defaults

# ビルド＆シミュレータ実行
mcp__XcodeBuildMCP__build_run_sim (scheme: "Seednote")

# テスト実行
mcp__XcodeBuildMCP__test_sim (scheme: "SeednoteTests")
```

## アーキテクチャ

```
Seednote/
├── App/          # SeednoteApp, AppRouter (DIコンテナ/シングルトン), RootView
├── Models/       # SwiftData モデル (Fragment, GeneratedDraft) + Enum
├── Services/
│   ├── AI/              # AIAnalysisServiceProtocol, MockAIAnalysisService, PromptBuilder
│   ├── Export/          # ClipboardService
│   ├── Recommendation/  # RelatedFragmentServiceProtocol → RelatedFragmentService
│   ├── Storage/         # FragmentRepositoryProtocol → SwiftDataFragmentRepository
│   └── Subscription/    # SubscriptionServiceProtocol, UsageLimitService
├── Views/
│   ├── Components/      # 共通UIコンポーネント
│   ├── Detail/          # Fragment詳細画面
│   ├── Editor/          # Fragment編集画面
│   ├── GeneratedDraft/  # AI下書き画面
│   ├── Home/            # ホーム画面 (一覧・検索・フィルタ)
│   └── Settings/        # 設定画面
├── DesignSystem/  # Colors, Spacing, Typography, View+CardStyle
└── Utils/         # Extensions (+Ext命名), PreviewData
```

- **MVVM**: 各画面に `View` + `ViewModel` のペア
- **DI**: `AppRouter.shared` が全サービスのインスタンスを保持し、ViewModel の init で注入
- **Protocol-first**: すべてのサービスにプロトコルを定義し、具象クラスで実装

## コーディング規約

### ViewModel
- `@MainActor` を必ず付与する
- `ObservableObject` に準拠し、`@Published` でプロパティを公開する
- init でプロトコル型の依存を受け取る

### Model
- SwiftData の `@Model` を使用する
- ID には `@Attribute(.unique) var id: UUID` を使用する
- Enum の値は `rawValue: String` で保持し、computed property で型変換する

### Enum
- `rawValue` は英語の `String`
- `displayName` computed property で日本語表示名を返す
- `CaseIterable` に準拠する

### Service
- プロトコルを先に定義する（例: `FragmentRepositoryProtocol`）
- 具象クラスは別ファイルで実装する（例: `SwiftDataFragmentRepository`）

### DesignSystem
- 色は `Colors` の static プロパティを使う
- 余白は `Spacing` の static プロパティを使う
- タイポグラフィは `Typography` の static プロパティを使う
- カードスタイルは `View+CardStyle` の ViewModifier を使う

### ファイル命名
- Extension ファイルは `型名+Ext.swift`（例: `String+Ext.swift`）
- ViewModifier ファイルは `View+機能名.swift`（例: `View+CardStyle.swift`）

### UI
- ユーザー向け文字列はすべて日本語で記述する

## TDD ルール（t-wada スタイル）

テスト駆動開発を厳格に守ること。

### 基本サイクル: Red → Green → Refactor

1. **Red**: まずテストを1つだけ書き、失敗することを確認する
2. **Green**: そのテストを通すための最小限の実装コードだけを書く
3. **Refactor**: テストが通った状態を維持しながらリファクタリングする

### 厳守事項

- **テストを先に書く。** 実装コードを先に書いてはならない
- **Red の状態で、テストは1つだけ追加する。** 複数のテストを一度に追加しない
- **Green では最小限の実装のみ。** 将来のためのコードを書かない
- **Refactor フェーズを必ず確認する。** スキップしない
- **各フェーズでテストを実行して状態を確認する**

### テストフレームワーク

Swift Testing（`@Test`, `#expect`）を使用する。XCTest は使わない。

```swift
import Testing

struct FragmentTests {
    @Test func フラグメントの初期ステータスは未整理である() {
        let fragment = Fragment()
        #expect(fragment.status == .unprocessed)
    }
}
```

### テストの書き方

- テスト関数名は日本語で、テストの意図を明確に記述する
- Arrange-Act-Assert パターンに従う
- プロトコルを活用してモックを作成する
- テスト実行には `mcp__XcodeBuildMCP__test_sim` を使用する
