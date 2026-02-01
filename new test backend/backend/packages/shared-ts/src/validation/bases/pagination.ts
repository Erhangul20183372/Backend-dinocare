import z from "zod";

export const pagination = ({ max = 100, default: defaultLimit = 100 }) =>
  z.object({
    limit: z.coerce.number().int().min(1).max(max).default(defaultLimit),
    offset: z.coerce.number().int().min(0).max(max).default(0),
  });
