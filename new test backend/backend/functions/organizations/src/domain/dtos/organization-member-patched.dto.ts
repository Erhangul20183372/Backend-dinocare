import { organizationRoles, OrganizationRole } from "@shared/ts/entities";
import { z } from "zod";

export const organizationMemberPatchedSchema = z.object({
  id: z.string().uuid(),
  appUserId: z.string().uuid(),
  role: z.enum(organizationRoles).default(OrganizationRole.ORGANIZATION_MEMBER),
});

export type OrganizationMemberPatchedDto = z.infer<typeof organizationMemberPatchedSchema>;
