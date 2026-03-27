# Seednote AI API Worker

Cloudflare Workers 上で動く Seednote の AI BFF です。Cloudflare AI Gateway を経由して LLM にアクセスします。

## Endpoints

- `POST /v1/analyze`
- `POST /v1/drafts`

## Required Environment Variables

- `AI_GATEWAY_ACCOUNT_ID`
- `AI_GATEWAY_GATEWAY_ID`
- `AI_GATEWAY_API_TOKEN`
- `AI_MODEL`

## Optional Environment Variables

- `WORKER_API_TOKEN`

## Local Development

```bash
pnpm install
pnpm --filter @seednote/ai-api check
pnpm --filter @seednote/ai-api dev
```

`WORKER_API_TOKEN` を設定した場合、iOS 側は `Authorization: Bearer <token>` を付与します。
