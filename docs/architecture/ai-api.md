# AI API Architecture

Seednote の AI API は Cloudflare Workers 上の BFF として実装し、iOS アプリから直接モデルプロバイダへ接続しません。

## Responsibilities

- iOS からの入力を API 契約に沿って検証する
- Cloudflare AI Gateway を通じて LLM を呼ぶ
- モデル応答を契約形に正規化する
- 将来の認証、レート制限、監査ログ追加の入口を提供する

## Directory Policy

- `backend/contracts/` を API 契約の唯一の正本とする
- `Seednote/Services/AI/DTO` は契約に従う iOS 側 DTO を置く
- `Seednote/Services/AI/Client` は transport と request builder を置く
- `Seednote/Services/AI/Mock` は UI 開発用 mock 実装を置く
