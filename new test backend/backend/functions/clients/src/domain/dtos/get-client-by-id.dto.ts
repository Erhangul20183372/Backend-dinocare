import { genders } from "@shared/ts/entities";
import { z } from "zod";

export const getClientByIdSchema = z.object({
  id: z.string().uuid(),
  gender: z.enum(genders),
  firstName: z.string(),
  lastName: z.string(),
  teamId: z.string().uuid(),
});

export type ClientsByIdDto = z.infer<typeof getClientByIdSchema>;
