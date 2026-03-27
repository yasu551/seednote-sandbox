import test from "node:test";
import assert from "node:assert/strict";

import { AIAPIService } from "../src/domain/ai-api-service";
import { AppError } from "../src/lib/errors";
import { getWorkerConfig } from "../src/lib/env";
import { handleAnalyze } from "../src/routes/analyze";
import { handleDrafts } from "../src/routes/drafts";

test("AIAPIServiceはanalyzeの正常系レスポンスを返す", async () => {
  const service = new AIAPIService({
    async generateJSON() {
      return JSON.stringify({
        summary: "要約",
        type: "idea",
        question: "問い",
        claim: "主張",
        image: "📝",
        useCases: ["用途1"],
      });
    },
  });

  const result = await service.analyze({ fragmentText: "断片" });

  assert.equal(result.type, "idea");
  assert.deepEqual(result.useCases, ["用途1"]);
});

test("AIAPIServiceはdraftsの正常系レスポンスを返す", async () => {
  const service = new AIAPIService({
    async generateJSON() {
      return JSON.stringify({
        content: "本文",
      });
    },
  });

  const result = await service.generateDraft({
    fragmentText: "断片",
    template: "essayOutline",
  });

  assert.equal(result.content, "本文");
});

test("handleAnalyzeは不正payloadを400として扱う", async () => {
  const service = new AIAPIService({
    async generateJSON() {
      return "{}";
    },
  });
  const request = new Request("https://example.com/v1/analyze", {
    method: "POST",
    body: JSON.stringify({ fragmentText: "" }),
  });

  await assert.rejects(() => handleAnalyze(request, service), (error: unknown) => {
    assert.ok(error instanceof AppError);
    assert.equal(error.status, 400);
    return true;
  });
});

test("AIAPIServiceはAI Gatewayエラーをそのまま伝播する", async () => {
  const service = new AIAPIService({
    async generateJSON() {
      throw new AppError(429, "gateway_error", "rate limited");
    },
  });

  await assert.rejects(() => service.analyze({ fragmentText: "断片" }), (error: unknown) => {
    assert.ok(error instanceof AppError);
    assert.equal(error.status, 429);
    assert.equal(error.message, "rate limited");
    return true;
  });
});

test("getWorkerConfigは必須env不足を500として扱う", () => {
  assert.throws(
    () =>
      getWorkerConfig({
        AI_GATEWAY_ACCOUNT_ID: "acc",
      }),
    (error: unknown) => {
      assert.ok(error instanceof AppError);
      assert.equal(error.status, 500);
      assert.equal(error.message, "AI_GATEWAY_GATEWAY_ID is required");
      return true;
    },
  );
});

test("handleDraftsは正常payloadを受け付ける", async () => {
  const service = new AIAPIService({
    async generateJSON() {
      return JSON.stringify({
        content: "生成結果",
      });
    },
  });
  const request = new Request("https://example.com/v1/drafts", {
    method: "POST",
    body: JSON.stringify({ fragmentText: "断片", template: "appIdea" }),
  });

  const result = await handleDrafts(request, service);

  assert.equal(result.content, "生成結果");
});
