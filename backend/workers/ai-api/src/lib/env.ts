import { AppError } from "./errors";
import type { Env, WorkerConfig } from "../types/env";

export const getWorkerConfig = (env: Env): WorkerConfig => {
  const gatewayAccountId = requireEnv(env.AI_GATEWAY_ACCOUNT_ID, "AI_GATEWAY_ACCOUNT_ID");
  const gatewayId = requireEnv(env.AI_GATEWAY_GATEWAY_ID, "AI_GATEWAY_GATEWAY_ID");
  const gatewayApiToken = requireEnv(env.AI_GATEWAY_API_TOKEN, "AI_GATEWAY_API_TOKEN");
  const model = requireEnv(env.AI_MODEL, "AI_MODEL");

  return {
    gatewayAccountId,
    gatewayId,
    gatewayApiToken,
    model,
    workerApiToken: env.WORKER_API_TOKEN,
  };
};

const requireEnv = (value: string | undefined, name: string): string => {
  if (!value) {
    throw new AppError(500, "missing_env", `${name} is required`);
  }

  return value;
};
