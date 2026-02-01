import { z } from "zod";

export const allOrganizationsSchema = z.object({
  id: z.string().uuid(),
  domain: z.string(),
  name: z.string(),
  logoUrl: z.string().nullable(),
});

export type AllOrganizationsDto = z.infer<typeof allOrganizationsSchema>;
