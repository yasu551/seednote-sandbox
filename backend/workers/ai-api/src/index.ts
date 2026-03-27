import { AIAPIService } from "./domain/ai-api-service";
import { CloudflareAIGatewayClient } from "./gateway/ai-gateway-client";
import { getWorkerConfig } from "./lib/env";
import { AppError, isAppError } from "./lib/errors";
import { json } from "./lib/json";
import { handleAnalyze } from "./routes/analyze";
import { handleDrafts } from "./routes/drafts";
import type { Env } from "./types/env";

export const handleRequest = async (request: Request, env: Env): Promise<Response> => {
  try {
    const config = getWorkerConfig(env);
    authorizeRequest(request, config.workerApiToken);

    const service = new AIAPIService(new CloudflareAIGatewayClient(config));
    const url = new URL(request.url);

    if (request.method === "POST" && url.pathname === "/v1/analyze") {
      return json(await handleAnalyze(request, service));
    }

    if (request.method === "POST" && url.pathname === "/v1/drafts") {
      return json(await handleDrafts(request, service));
    }

    return json(
      { error: { code: "not_found", message: "Not found" } },
      { status: 404 },
    );
  } catch (error) {
    return handleError(error);
  }
};

const authorizeRequest = (request: Request, workerApiToken?: string) => {
  if (!workerApiToken) {
    return;
  }

  const header = request.headers.get("authorization");
  if (header !== `Bearer ${workerApiToken}`) {
    throw new AppError(401, "unauthorized", "Invalid API token");
  }
};

const handleError = (error: unknown): Response => {
  if (isAppError(error)) {
    return json(
      { error: { code: error.code, message: error.message } },
      { status: error.status },
    );
  }

  return json(
    { error: { code: "internal_error", message: "Unexpected internal error" } },
    { status: 500 },
  );
};

export default {
  fetch: (request: Request, env: Env) => handleRequest(request, env),
};
