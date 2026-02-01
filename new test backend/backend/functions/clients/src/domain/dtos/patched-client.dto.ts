import { genders } from "@shared/ts/entities";
import { z } from "zod";

export const patchedClientSchema = z.object({
  id: z.string().uuid(),
  gender: z.enum(genders),
  firstName: z.string(),
  lastName: z.string(),
  teamId: z.string().uuid(),
  archived_on: z.date().nullable(),
  archived_by: z.string().uuid().nullable(),
});

export type PatchedClientDto = z.infer<typeof patchedClientSchema>;
