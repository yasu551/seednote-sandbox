import {
  analyzeResponseSchema,
  draftResponseSchema,
  type AnalyzeRequest,
  type AnalyzeResponse,
  type DraftRequest,
  type DraftResponse,
} from "../schemas/ai-api";
import { AppError } from "../lib/errors";
import { buildAnalyzeMessages, buildDraftMessages } from "./prompts";
import type { AIGatewayClient } from "../gateway/ai-gateway-client";

export class AIAPIService {
  constructor(private readonly gatewayClient: AIGatewayClient) {}

  async analyze(input: AnalyzeRequest): Promise<AnalyzeResponse> {
    const { systemPrompt, userPrompt } = buildAnalyzeMessages(input.fragmentText);
    const raw = await this.gatewayClient.generateJSON(systemPrompt, userPrompt);
    return parseModelJSON(raw, analyzeResponseSchema, "invalid_analyze_response");
  }

  async generateDraft(input: DraftRequest): Promise<DraftResponse> {
    const { systemPrompt, userPrompt } = buildDraftMessages(input.fragmentText, input.template);
    const raw = await this.gatewayClient.generateJSON(systemPrompt, userPrompt);
    return parseModelJSON(raw, draftResponseSchema, "invalid_draft_response");
  }
}

const parseModelJSON = <T>(
  raw: string,
  schema: { safeParse: (value: unknown) => { success: true; data: T } | { success: false } },
  code: string,
): T => {
  let parsed: unknown;

  try {
    parsed = JSON.parse(raw);
  } catch {
    throw new AppError(502, code, "Model response was not valid JSON");
  }

  const result = schema.safeParse(parsed);
  if (!result.success) {
    throw new AppError(502, code, "Model response did not match the API contract");
  }

  return result.data;
};
