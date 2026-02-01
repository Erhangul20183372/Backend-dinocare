import { z } from "zod";

export const allOrganizationTeamsSchema = z.object({
  id: z.string().uuid(),
  domain: z.string(),
  name: z.string(),
  logoUrl: z.string().nullable(),
  teams: z.array(
    z.object({
      id: z.string().uuid(),
      name: z.string(),
      color: z.string(),
    })
  ),
});

export type AllOrganizationTeamsDto = z.infer<typeof allOrganizationTeamsSchema>;
