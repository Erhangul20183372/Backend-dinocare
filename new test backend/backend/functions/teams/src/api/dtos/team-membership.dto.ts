import { teamRoles } from "@shared/ts/entities";
import { composeDto, isValidDateTime, isValidEnum, isValidUUID, pagination } from "@shared/ts/validation";
import z from "zod";

const teamMembershipBaseSchema = z.object({
  teamId: isValidUUID,
  appUserId: isValidUUID,
  role: isValidEnum(teamRoles),
  memberSince: isValidDateTime.optional(),
  memberUntil: isValidDateTime.optional(),
});

export const { schema: createTeamMembershipSchema, dto: CreateTeamMembershipDto } = composeDto({
  params: teamMembershipBaseSchema.pick({ teamId: true }),
  body: teamMembershipBaseSchema
    .pick({ appUserId: true, role: true, memberSince: true, memberUntil: true })
    .partial({ memberSince: true, memberUntil: true }),
});
export type CreateTeamMembershipDto = z.infer<typeof CreateTeamMembershipDto>;

export const { schema: getTeamMembersSchema, dto: GetTeamMembersDto } = composeDto({
  params: teamMembershipBaseSchema.pick({ teamId: true }),
  query: pagination({ max: 100, default: 100 }).merge(
    teamMembershipBaseSchema.pick({ role: true }).partial({ role: true })
  ),
});
export type GetTeamMembersDto = z.infer<typeof GetTeamMembersDto>;

export const { schema: patchTeamMembershipSchema, dto: PatchTeamMembershipDto } = composeDto({
  params: teamMembershipBaseSchema.pick({ teamId: true, appUserId: true }),
  body: teamMembershipBaseSchema
    .pick({ role: true, memberSince: true, memberUntil: true })
    .partial({ role: true, memberSince: true, memberUntil: true })
    .refine((data) => Object.keys(data).length > 0, {
      message: "At least one property must be provided",
    }),
});
export type PatchTeamMembershipDto = z.infer<typeof PatchTeamMembershipDto>;

export const { schema: deleteTeamMembershipSchema, dto: DeleteTeamMembershipDto } = composeDto({
  params: teamMembershipBaseSchema.pick({ teamId: true, appUserId: true }),
});
export type DeleteTeamMembershipDto = z.infer<typeof DeleteTeamMembershipDto>;
