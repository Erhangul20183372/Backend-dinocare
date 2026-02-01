import { genders } from "@shared/ts/entities";
import { z } from "zod";

export const allOrganizationClientsSchema = z.object({
  id: z.string().uuid(),
  domain: z.string(),
  name: z.string(),
  logoUrl: z.string().nullable(),
  clients: z.array(
    z.object({
      id: z.string().uuid(),
      teamId: z.string().uuid(),
      firstName: z.string(),
      lastName: z.string(),
      gender: z.enum(genders),
    })
  ),
});

export type AllOrganizationClientsDto = z.infer<typeof allOrganizationClientsSchema>;
