import { z } from "zod";

export const organizationPatchedSchema = z.object({
  id: z.string().uuid(),
  domain: z.string(),
  name: z.string(),
  logoUrl: z.string().nullable(),
});

export type OrganizationPatchedDto = z.infer<typeof organizationPatchedSchema>;
