import {
  composeDto,
  isValidDomain,
  isValidString,
  isValidURL,
  isValidUUID,
  pagination,
  search,
} from "@shared/ts/validation";
import z from "zod";

const organizationBaseSchema = z.object({
  id: isValidUUID,
  name: isValidString,
  domain: isValidDomain,
  logoUrl: isValidURL.nullable(),
});

export const { schema: createOrganizationSchema, dto: CreateOrganizationDto } = composeDto({
  body: organizationBaseSchema.pick({ name: true, domain: true, logoUrl: true }).partial({ logoUrl: true }),
});
export type CreateOrganizationDto = z.infer<typeof CreateOrganizationDto>;

export const { schema: getOrganizationsSchema, dto: GetOrganizationsDto } = composeDto({
  query: pagination({ max: 100, default: 100 }),
});
export type GetOrganizationsDto = z.infer<typeof GetOrganizationsDto>;

export const { schema: getOrganizationByIdSchema, dto: GetOrganizationByIdDto } = composeDto({
  params: organizationBaseSchema.pick({ id: true }),
});
export type GetOrganizationByIdDto = z.infer<typeof GetOrganizationByIdDto>;

export const { schema: patchOrganizationSchema, dto: PatchOrganizationDto } = composeDto({
  params: organizationBaseSchema.pick({ id: true }),
  body: organizationBaseSchema.partial().pick({ name: true, domain: true, logoUrl: true }),
});
export type PatchOrganizationDto = z.infer<typeof PatchOrganizationDto>;

export const { schema: deleteOrganizationSchema, dto: DeleteOrganizationDto } = composeDto({
  params: organizationBaseSchema.pick({ id: true }),
});
export type DeleteOrganizationDto = z.infer<typeof DeleteOrganizationDto>;

export const { schema: getOrganizationTeamsSchema, dto: GetOrganizationTeamsDto } = composeDto({
  params: organizationBaseSchema.pick({ id: true }),
  query: pagination({ max: 100, default: 100 }).merge(search),
});
export type GetOrganizationTeamsDto = z.infer<typeof GetOrganizationTeamsDto>;

export const { schema: getOrganizationClientsSchema, dto: GetOrganizationClientsDto } = composeDto({
  params: organizationBaseSchema.pick({ id: true }),
  query: pagination({ max: 100, default: 100 }).merge(search),
});
export type GetOrganizationClientsDto = z.infer<typeof GetOrganizationClientsDto>;
