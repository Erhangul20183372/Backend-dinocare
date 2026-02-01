import { z } from "zod";

export const oneOrganizationSchema = z.object({
  id: z.string().uuid(),
  domain: z.string(),
  name: z.string(),
  logoUrl: z.string().nullable(),
});

export type OneOrganizationDto = z.infer<typeof oneOrganizationSchema>;
