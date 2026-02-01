import { organizationRoles, OrganizationRole } from "@shared/ts/entities";
import { z } from "zod";

export const organizationMemberCreatedSchema = z.object({
  id: z.string().uuid(),
  appUserId: z.string().uuid(),
  role: z.enum(organizationRoles).default(OrganizationRole.ORGANIZATION_MEMBER),
  invitedBy: z.string().uuid(),
  memberSince: z.date(),
});

export type OrganizationMemberCreatedDto = z.infer<typeof organizationMemberCreatedSchema>;
