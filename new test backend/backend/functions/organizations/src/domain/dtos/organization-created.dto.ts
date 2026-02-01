import { z } from "zod";

export const organizationCreatedSchema = z.object({
  id: z.string().uuid(),
  domain: z.string(),
  name: z.string(),
  logoUrl: z.string().nullable(),
});

export type OrganizationCreatedDto = z.infer<typeof organizationCreatedSchema>;
