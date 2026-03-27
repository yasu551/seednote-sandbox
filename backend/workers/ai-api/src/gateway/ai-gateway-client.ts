import { AppError } from "../lib/errors";
import type { WorkerConfig } from "../types/env";

export interface AIGatewayClient {
  generateJSON(systemPrompt: string, userPrompt: string): Promise<string>;
}

interface ChatCompletionResponse {
  choices?: Array<{
    message?: {
      content?: string;
    };
  }>;
  error?: {
    message?: string;
  };
}

export class CloudflareAIGatewayClient implements AIGatewayClient {
  constructor(
    private readonly config: WorkerConfig,
    private readonly fetcher: typeof fetch = fetch,
  ) {}

  async generateJSON(systemPrompt: string, userPrompt: string): Promise<string> {
    const response = await this.fetcher(
      `https://gateway.ai.cloudflare.com/v1/${this.config.gatewayAccountId}/${this.config.gatewayId}/openai/chat/completions`,
      {
        method: "POST",
        headers: {
          "content-type": "application/json",
          authorization: `Bearer ${this.config.gatewayApiToken}`,
        },
        body: JSON.stringify({
          model: this.config.model,
          response_format: { type: "json_object" },
          messages: [
            { role: "system", content: systemPrompt },
            { role: "user", content: userPrompt },
          ],
        }),
      },
    );

    const payload = (await response.json()) as ChatCompletionResponse;

    if (!response.ok) {
      throw new AppError(
        response.status,
        "gateway_error",
        payload.error?.message ?? "AI Gateway request failed",
      );
    }

    const content = payload.choices?.[0]?.message?.content;
    if (!content) {
      throw new AppError(502, "invalid_gateway_response", "AI Gateway response did not contain content");
    }

    return content;
  }
}
