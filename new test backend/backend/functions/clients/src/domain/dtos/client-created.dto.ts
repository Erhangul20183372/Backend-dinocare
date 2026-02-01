import { genders } from "@shared/ts/entities";
import { z } from "zod";

export const clientCreatedSchema = z.object({
  id: z.string().uuid(),
  teamId: z.string().uuid(),
  gender: z.enum(genders),
  firstName: z.string(),
  lastName: z.string(),
});

export type ClientCreatedDto = z.infer<typeof clientCreatedSchema>;
