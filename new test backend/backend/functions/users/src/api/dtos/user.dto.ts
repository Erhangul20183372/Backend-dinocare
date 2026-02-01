import { organizationRoles, teamRoles } from "@shared/ts/entities";
import { composeDto, isValidEnum, isValidString, isValidUUID, pagination, search } from "@shared/ts/validation";
import z from "zod";

const appUserBaseSchema = z.object({
  id: isValidUUID,
  firstName: isValidString,
  lastName: isValidString,
  teamId: isValidUUID,
  teamRole: isValidEnum(teamRoles),
  organizationId: isValidUUID,
  organizationRole: isValidEnum(organizationRoles),
});

export const { schema: getUsersSchema, dto: GetUsersDto } = composeDto({
  query: pagination({ max: 100, default: 100 })
    .merge(search)
    .merge(appUserBaseSchema.pick({ teamId: true, teamRole: true, organizationId: true, organizationRole: true }))
    .partial({ teamId: true, teamRole: true, organizationId: true, organizationRole: true }),
});
export type GetUsersDto = z.infer<typeof GetUsersDto>;

export const { schema: getUserByIdSchema, dto: GetUserByIdDto } = composeDto({
  params: appUserBaseSchema.pick({ id: true }),
});
export type GetUserByIdDto = z.infer<typeof GetUserByIdDto>;

export const { schema: patchUserSchema, dto: PatchUserDto } = composeDto({
  params: appUserBaseSchema.pick({ id: true }),
  body: appUserBaseSchema
    .pick({ firstName: true, lastName: true })
    .partial({ firstName: true, lastName: true })
    .refine((data) => Object.keys(data).length > 0, { message: "At least one field must be provided to update." }),
});
export type PatchUserDto = z.infer<typeof PatchUserDto>;

export const { schema: archiveUserSchema, dto: ArchiveUserDto } = composeDto({
  params: appUserBaseSchema.pick({ id: true }),
});
export type ArchiveUserDto = z.infer<typeof ArchiveUserDto>;
