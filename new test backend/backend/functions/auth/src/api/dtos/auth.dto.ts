import { OrganizationRole, organizationRoles } from "@shared/ts/entities";
import {
  composeDto,
  isValidEmail,
  isValidEnum,
  isValidPassword,
  isValidString,
  isValidUUID,
} from "@shared/ts/validation";
import z from "zod";

const authBaseSchema = z.object({
  emailAddress: isValidEmail,
  password: isValidPassword,
  firstName: isValidString,
  lastName: isValidString,
  role: isValidEnum(organizationRoles).default(OrganizationRole.ORGANIZATION_MEMBER),
  refreshToken: isValidString,
});

export const { schema: registerSchema, dto: RegisterDto } = composeDto({
  body: authBaseSchema.pick({ emailAddress: true, password: true, firstName: true, lastName: true, role: true }),
});
export type RegisterDto = z.infer<typeof registerSchema.body>;

export const { schema: loginSchema, dto: LoginDto } = composeDto({
  body: authBaseSchema.pick({ emailAddress: true, password: true }),
});
export type LoginDto = z.infer<typeof loginSchema.body>;

export const { schema: refreshSchema, dto: RefreshDto } = composeDto({
  body: authBaseSchema.pick({ refreshToken: true }),
});
export type RefreshDto = z.infer<typeof refreshSchema.body>;
