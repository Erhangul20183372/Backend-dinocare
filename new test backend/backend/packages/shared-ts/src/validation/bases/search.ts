import z from "zod";

export const search = z.object({
  search: z.string().min(1).max(100).optional(),
});
