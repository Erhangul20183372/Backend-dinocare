import bcrypt from "bcryptjs";
import { ENV } from "../env";

export async function comparePassword(candidatePassword: string, passwordHash: string): Promise<boolean> {
  return await bcrypt.compare(candidatePassword, passwordHash);
}

export async function hashPassword(password: string): Promise<string> {
  return await bcrypt.hash(password, ENV.SALT_ROUNDS);
}
