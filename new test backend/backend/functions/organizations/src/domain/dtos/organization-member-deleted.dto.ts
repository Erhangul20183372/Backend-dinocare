import { organizationRoles, OrganizationRole } from "@shared/ts/entities";
import { z } from "zod";

export const organizationMemberDeletedSchema = z.object({
  id: z.string().uuid(),
  appUserId: z.string().uuid(),
  role: z.enum(organizationRoles).default(OrganizationRole.ORGANIZATION_MEMBER),
  invitedBy: z.string().uuid(),
  memberSince: z.date(),
  memberUntil: z.date(),
  archivedOn: z.date(),
  archivedBy: z.string().uuid(),
});

export type OrganizationMemberDeletedDto = z.infer<typeof organizationMemberDeletedSchema>;
