export interface Env {
  AI_GATEWAY_ACCOUNT_ID?: string;
  AI_GATEWAY_GATEWAY_ID?: string;
  AI_GATEWAY_API_TOKEN?: string;
  AI_MODEL?: string;
  WORKER_API_TOKEN?: string;
}

export interface WorkerConfig {
  gatewayAccountId: string;
  gatewayId: string;
  gatewayApiToken: string;
  model: string;
  workerApiToken?: string;
}
