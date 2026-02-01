import { z } from "zod";
import { isValidEmail, isValidUUID, isValidString } from "../validation/index.js";

export class UserDTO {
  id!: string;
  firstName!: string;
  lastName!: string;
  emailAddress!: string;
  role!: string;
}

export const CreateUserSchema = z.object({
  firstName: isValidString,
  lastName: isValidString,
  emailAddress: isValidEmail,
});
export type CreateUserDTO = z.infer<typeof CreateUserSchema>;

export const GetUserSchema = z.object({
  userId: isValidUUID,
});
export type GetUserDTO = z.infer<typeof GetUserSchema>;
