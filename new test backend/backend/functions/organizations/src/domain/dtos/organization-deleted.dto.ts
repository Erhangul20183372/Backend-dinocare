import { z } from "zod";

export const organizationDeletedSchema = z.object({
  id: z.string().uuid(),
  domain: z.string(),
  name: z.string(),
  logoUrl: z.string().nullable(),
  archivedOn: z.date(),
  archivedBy: z.string().uuid(),
});

export type OrganizationDeletedDto = z.infer<typeof organizationDeletedSchema>;
