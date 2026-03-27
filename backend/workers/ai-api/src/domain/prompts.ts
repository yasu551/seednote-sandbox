import type { DraftRequest } from "../schemas/ai-api";

export const buildAnalyzeMessages = (fragmentText: string) => ({
  systemPrompt:
    "あなたはSeednoteの断片分析APIです。返答はJSONのみで行い、summary,type,question,claim,image,useCasesを必ず含めてください。",
  userPrompt: `以下の断片を日本語で分析してください。\n\n${fragmentText}`,
});

export const buildDraftMessages = (fragmentText: string, template: DraftRequest["template"]) => ({
  systemPrompt:
    "あなたはSeednoteのドラフト生成APIです。返答はJSONのみで行い、contentを必ず含めてください。",
  userPrompt: `以下の断片を「${template}」として再利用できる日本語ドラフトにしてください。\n\n${fragmentText}`,
});
