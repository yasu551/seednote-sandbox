import { analyzeRequestSchema } from "../schemas/ai-api";
import { AppError } from "../lib/errors";
import type { AIAPIService } from "../domain/ai-api-service";

export const handleAnalyze = async (request: Request, service: AIAPIService) => {
  const payload = await request.json();
  const result = analyzeRequestSchema.safeParse(payload);

  if (!result.success) {
    throw new AppError(400, "invalid_request", "fragmentText is required");
  }

  return service.analyze(result.data);
};
