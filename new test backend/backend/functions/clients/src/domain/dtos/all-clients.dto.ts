import { genders } from "@shared/ts/entities";
import { z } from "zod";

export const clientWithTeamSchema = z.object({
  id: z.string().uuid(),
  gender: z.enum(genders),
  firstName: z.string(),
  lastName: z.string(),
  teamId: z.string().uuid(),
  teamName: z.string(),
});

export type ClientWithTeamDto = z.infer<typeof clientWithTeamSchema>;
