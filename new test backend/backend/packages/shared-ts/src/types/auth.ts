import { mongoose } from "@typegoose/typegoose";
import { z } from "zod";
import { isValidEmail, isValidUUID, isValidString } from "../validation/index";
import { CreateUserSchema } from "./user";
import { Role } from "./index";

export interface AuthDTO {
  id: string;
  username: string;
  lastLogin?: Date;
  organization: { id: string; name?: string };
  role: Role;
}

export interface AccessTokenDTO {
  accessToken: string;
  refreshToken: string;
}

export interface JwtTokenDTO {
  userAuthId: string;
}

const PartialSignUpSchema = z.object({
  organizationId: isValidUUID,
  emailAddress: isValidEmail,
  password: z
    .string()
    .trim()
    .superRefine((password, ctx) => {
      if (password.length < 8) {
        ctx.addIssue({
          code: z.ZodIssueCode.too_small,
          minimum: 8,
          type: "string",
          inclusive: true,
          message: "Password must be at least 8 characters long",
        });
      }
      if (!/\d/.test(password)) {
        ctx.addIssue({ code: z.ZodIssueCode.custom, message: "Password must include at least 1 number" });
      }
      if (!/[A-Z]/.test(password)) {
        ctx.addIssue({ code: z.ZodIssueCode.custom, message: "Password must include at least 1 uppercase letter" });
      }
      if (!/[a-z]/.test(password)) {
        ctx.addIssue({ code: z.ZodIssueCode.custom, message: "Password must include at least 1 lowercase letter" });
      }
      if (!/[!@#$%^&*()\-_=+{}[\]:;<>,.?/~`"'\s]/.test(password)) {
        ctx.addIssue({ code: z.ZodIssueCode.custom, message: "Password must include at least 1 special character" });
      }
    }),
});

export const SignUpSchema = PartialSignUpSchema.merge(CreateUserSchema);
export type SignUpDTO = z.infer<typeof SignUpSchema>;

export interface CreateAuthUserDTO {
  username: string;
  password: string;
  organization: mongoose.Types.ObjectId;
}

export const RefreshSchema = z.object({
  refreshToken: isValidString.optional(),
});
export type RefreshDTO = z.infer<typeof RefreshSchema>;
