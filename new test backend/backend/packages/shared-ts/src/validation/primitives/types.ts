import { Base64 } from "js-base64";
import z from "zod";

export const isValidUUID = z.string().uuid();

export const isValidString = z.string().trim().min(1);

export const isValidBase64String = z.string().refine(Base64.isValid);

export const isValidDate = z.coerce.date();

export const isValidDateTime = z.string().datetime();
