import { entityStatuses, genders } from "@shared/ts/entities";
import { composeDto, isValidEnum, isValidString, isValidUUID, pagination, search } from "@shared/ts/validation";
import z from "zod";

const clientBaseSchema = z.object({
  id: isValidUUID,
  organizationId: isValidUUID,
  teamId: isValidUUID,
  gender: isValidEnum(genders),
  firstName: isValidString,
  lastName: isValidString,
  archivedOn: z.null(),
  archivedBy: z.null(),
  status: isValidEnum(entityStatuses),
});

export const { schema: createClientSchema, dto: CreateClientDto } = composeDto({
  body: clientBaseSchema.pick({ teamId: true, gender: true, firstName: true, lastName: true }),
});
export type CreateClientDto = z.infer<typeof CreateClientDto>;

export const { schema: createClientBulkSchema, dto: CreateClientBulkDto } = composeDto({
  body: z.object({
    clients: z.array(clientBaseSchema.pick({ teamId: true, gender: true, firstName: true, lastName: true })).min(1),
  }),
});
export type CreateClientBulkDto = z.infer<typeof CreateClientBulkDto>;

export const { schema: getClientsSchema, dto: GetClientsDto } = composeDto({
  query: pagination({ max: 100, default: 100 })
    .merge(search)
    .merge(
      clientBaseSchema
        .pick({ organizationId: true, teamId: true, status: true })
        .partial({ organizationId: true, teamId: true, status: true })
    ),
});
export type GetClientsDto = z.infer<typeof GetClientsDto>;

export const { schema: getClientByIdSchema, dto: GetClientByIdDto } = composeDto({
  params: clientBaseSchema.pick({ id: true }),
});
export type GetClientByIdDto = z.infer<typeof GetClientByIdDto>;

export const { schema: patchClientSchema, dto: PatchClientDto } = composeDto({
  params: clientBaseSchema.pick({ id: true }),
  body: clientBaseSchema
    .pick({ teamId: true, gender: true, firstName: true, lastName: true, archivedOn: true, archivedBy: true })
    .partial({ teamId: true, gender: true, firstName: true, lastName: true, archivedOn: true, archivedBy: true }),
});
export type PatchClientDto = z.infer<typeof PatchClientDto>;

export const { schema: deleteClientSchema, dto: DeleteClientDto } = composeDto({
  params: clientBaseSchema.pick({ id: true }),
});
export type DeleteClientDto = z.infer<typeof DeleteClientDto>;
