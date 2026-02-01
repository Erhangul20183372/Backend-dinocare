import { OrganizationRole, organizationRoles } from "@shared/ts/entities";
import { z } from "zod";

export const allOrganizationMembersSchema = z.object({
  id: z.string().uuid(),
  domain: z.string(),
  name: z.string(),
  logoUrl: z.string().nullable(),
  members: z.array(
    z.object({
      id: z.string().uuid(),
      role: z.enum(organizationRoles).default(OrganizationRole.ORGANIZATION_MEMBER),
    })
  ),
});

export type AllOrganizationMembersDto = z.infer<typeof allOrganizationMembersSchema>;
