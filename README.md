# Seednote Monorepo

Seednote は iOS アプリ本体と Cloudflare Workers ベースの AI API を同じリポジトリで管理します。

## Structure

- `Seednote/`: SwiftUI / SwiftData の iOS アプリ
- `SeednoteTests/`: Swift Testing ベースのテスト
- `backend/workers/ai-api/`: Cloudflare Workers API
- `backend/contracts/`: API 契約の正本
- `docs/architecture/`: 実装方針と運用ドキュメント

## iOS

```bash
xcodegen generate
xcodebuild \
  -project Seednote.xcodeproj \
  -scheme SeednoteTests \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /tmp/seednote-derived \
  CODE_SIGNING_ALLOWED=NO \
  build
```

`SEEDNOTE_API_BASE_URL` が未設定のとき、iOS アプリは `MockAIAnalysisService` を使います。

## Workers

```bash
pnpm install --ignore-scripts
pnpm worker:check
```

必要な環境変数名は `backend/workers/ai-api/README.md` に記載しています。

`worker:check` に必要なのは静的依存だけなので、検証用 install は `--ignore-scripts` を使います。
`pnpm worker:dev` を使う場合は、環境に応じて通常の `pnpm install` を使って Wrangler の実行時依存を解決してください。
