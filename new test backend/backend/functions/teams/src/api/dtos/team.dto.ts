import { isValidString, isValidUUID, isValidColor, composeDto, pagination, search } from "@shared/ts/validation";
import z from "zod";

const teamBaseSchema = z.object({
  id: isValidUUID,
  organizationId: isValidUUID,
  name: isValidString,
  color: isValidColor,
});

export const { schema: createTeamSchema, dto: CreateTeamDto } = composeDto({
  body: teamBaseSchema.pick({ name: true, organizationId: true, color: true }).partial({ color: true }),
});
export type CreateTeamDto = z.infer<typeof CreateTeamDto>;

export const { schema: bulkCreateTeamSchema, dto: BulkCreateTeamDto } = composeDto({
  body: z.object({
    teams: z.array(teamBaseSchema.pick({ name: true, organizationId: true, color: true }).partial({ color: true })),
  }),
});
export type BulkCreateTeamDto = z.infer<typeof BulkCreateTeamDto>;

export const { schema: getTeamsSchema, dto: GetTeamsDto } = composeDto({
  query: pagination({ max: 100, default: 100 })
    .merge(search)
    .merge(teamBaseSchema.pick({ organizationId: true }).partial({ organizationId: true })),
});
export type GetTeamsDto = z.infer<typeof GetTeamsDto>;

export const { schema: getTeamByIdSchema, dto: GetTeamByIdDto } = composeDto({
  params: teamBaseSchema.pick({ id: true }),
});
export type GetTeamByIdDto = z.infer<typeof GetTeamByIdDto>;

export const { schema: patchTeamSchema, dto: PatchTeamDto } = composeDto({
  params: teamBaseSchema.pick({ id: true }),
  body: teamBaseSchema
    .pick({ name: true, color: true })
    .partial({ name: true, color: true })
    .refine((data) => Object.keys(data).length > 0, {
      message: "At least one property must be provided",
    }),
});
export type PatchTeamDto = z.infer<typeof PatchTeamDto>;

export const { schema: deleteTeamSchema, dto: DeleteTeamDto } = composeDto({
  params: teamBaseSchema.pick({ id: true }),
});
export type DeleteTeamDto = z.infer<typeof DeleteTeamDto>;

export const { schema: getTeamClientsSchema, dto: GetTeamClientsDto } = composeDto({
  params: teamBaseSchema.pick({ id: true }),
  query: pagination({ max: 100, default: 100 }).merge(search),
});
export type GetTeamClientsDto = z.infer<typeof GetTeamClientsDto>;
