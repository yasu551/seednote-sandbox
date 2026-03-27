import { z } from "zod";

export const analyzeRequestSchema = z.object({
  fragmentText: z.string().trim().min(1),
});

export const analyzeResponseSchema = z.object({
  summary: z.string().min(1),
  type: z.enum(["question", "claim", "idea", "world", "observation"]),
  question: z.string().min(1),
  claim: z.string().min(1),
  image: z.string().min(1),
  useCases: z.array(z.string().min(1)).min(1),
});

export const draftRequestSchema = z.object({
  fragmentText: z.string().trim().min(1),
  template: z.enum(["essayOutline", "shortStoryCore", "appIdea"]),
});

export const draftResponseSchema = z.object({
  content: z.string().min(1),
});

export type AnalyzeRequest = z.infer<typeof analyzeRequestSchema>;
export type AnalyzeResponse = z.infer<typeof analyzeResponseSchema>;
export type DraftRequest = z.infer<typeof draftRequestSchema>;
export type DraftResponse = z.infer<typeof draftResponseSchema>;
