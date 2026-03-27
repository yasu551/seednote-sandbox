import { draftRequestSchema } from "../schemas/ai-api";
import { AppError } from "../lib/errors";
import type { AIAPIService } from "../domain/ai-api-service";

export const handleDrafts = async (request: Request, service: AIAPIService) => {
  const payload = await request.json();
  const result = draftRequestSchema.safeParse(payload);

  if (!result.success) {
    throw new AppError(400, "invalid_request", "fragmentText and template are required");
  }

  return service.generateDraft(result.data);
};
