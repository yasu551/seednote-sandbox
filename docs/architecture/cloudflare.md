# Cloudflare Setup

## Worker

- サービス名: `seednote-ai-api`
- ランタイム: Cloudflare Workers
- API パス: `/v1/analyze`, `/v1/drafts`

## Environment Variables

- `AI_GATEWAY_ACCOUNT_ID`
- `AI_GATEWAY_GATEWAY_ID`
- `AI_GATEWAY_API_TOKEN`
- `AI_MODEL`
- `WORKER_API_TOKEN` 任意

## Operational Notes

- `backend/contracts/ai-api.openapi.yaml` を変更したら iOS DTO と Worker schema を同時に見直す
- deploy workflow は `backend/workers/ai-api/**` と `backend/contracts/**` の変更時のみ起動する
