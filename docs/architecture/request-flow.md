# Request Flow

1. iOS の `AIAnalysisService` が `APIConfiguration` を読み込む
2. `SEEDNOTE_API_BASE_URL` があれば `RemoteAIAnalysisService` を選ぶ
3. iOS が `/v1/analyze` または `/v1/drafts` に JSON を送る
4. Worker が Zod で payload を検証する
5. Worker が AI Gateway に JSON 出力を要求する
6. Worker がモデル応答を契約形に検証して返す

設定が無い環境では `MockAIAnalysisService` が使われるため、UI 開発を止めずに進められます。
