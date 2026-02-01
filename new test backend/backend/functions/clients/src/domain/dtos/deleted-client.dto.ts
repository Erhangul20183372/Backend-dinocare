import { genders } from "@shared/ts/entities";
import { z } from "zod";

export const deletedClientSchema = z.object({
  id: z.string().uuid(),
  gender: z.enum(genders),
  firstName: z.string(),
  lastName: z.string(),
  teamId: z.string().uuid(),
  archivedOn: z.date().nullable(),
  archivedBy: z.string().uuid().nullable(),
});

export type DeletedClientDto = z.infer<typeof deletedClientSchema>;
