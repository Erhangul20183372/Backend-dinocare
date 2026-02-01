import { organizationRoles } from "@shared/ts/entities";
import { composeDto, isValidEnum, isValidUUID, pagination } from "@shared/ts/validation";
import z from "zod";

const organizationMembershipBaseSchema = z.object({
  appUserId: isValidUUID,
  organizationId: isValidUUID,
  role: isValidEnum(organizationRoles),
});

export const { schema: createOrganizationMembershipSchema, dto: CreateOrganizationMembershipDto } = composeDto({
  params: organizationMembershipBaseSchema.pick({ organizationId: true }),
  body: organizationMembershipBaseSchema.pick({ appUserId: true, role: true }),
});
export type CreateOrganizationMembershipDto = z.infer<typeof CreateOrganizationMembershipDto>;

export const { schema: getOrganizationMembershipsSchema, dto: GetOrganizationMembershipsDto } = composeDto({
  params: organizationMembershipBaseSchema.pick({ organizationId: true }),
  query: pagination({ max: 100, default: 100 }).merge(
    organizationMembershipBaseSchema.pick({ role: true }).partial({ role: true })
  ),
});
export type GetOrganizationMembershipsDto = z.infer<typeof GetOrganizationMembershipsDto>;

export const { schema: patchOrganizationMembershipSchema, dto: PatchOrganizationMembershipDto } = composeDto({
  params: organizationMembershipBaseSchema.pick({ organizationId: true, appUserId: true }),
  body: organizationMembershipBaseSchema.pick({ role: true }),
});
export type PatchOrganizationMembershipDto = z.infer<typeof PatchOrganizationMembershipDto>;

export const { schema: deleteOrganizationMembershipSchema, dto: DeleteOrganizationMembershipDto } = composeDto({
  params: organizationMembershipBaseSchema.pick({ organizationId: true, appUserId: true }),
});
export type DeleteOrganizationMembershipDto = z.infer<typeof DeleteOrganizationMembershipDto>;
