import z from "zod";

export const isValidEmail = z.string().trim().email();

export const isValidPassword = z
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
  });

export const isValidDomain = z
  .string()
  .trim()
  .regex(/^(?!:\/\/)([a-zA-Z0-9-_]+\.)+[a-zA-Z]{2,}$/);

export const isValidEnum = <TEnum extends string>(choices: readonly TEnum[]) => z.enum(choices as [TEnum, ...TEnum[]]);

export const isValidColor = z
  .string()
  .regex(/^#[0-9A-Fa-f]{6}$/)
  .describe("Hex color in the form #RRGGBB");

export const isValidStickerId = z.string().length(6).describe("Sticker ID must be exactly 6 characters long");

export const isValidSerialNumber = z.string().length(6).describe("Serial Number must be exactly 6 characters long");

export const isValidURL = z.string().url();
