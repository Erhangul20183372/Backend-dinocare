import jwt, { SignOptions } from "jsonwebtoken";
import { ENV } from "../env";

export function generateAccessToken(appUserId: string): string {
  const payload = { appUserId };
  const opts: SignOptions = { expiresIn: ENV.JWT_ACCESS_EXPIRATION as any, algorithm: "HS256" };
  return jwt.sign(payload, ENV.JWT_ACCESS_SECRET as string, opts);
}

export function generateRefreshToken(appUserId: string): string {
  const payload = { appUserId };
  const opts: SignOptions = { expiresIn: ENV.JWT_REFRESH_EXPIRATION as any, algorithm: "HS256" };
  return jwt.sign(payload, ENV.JWT_REFRESH_SECRET as string, opts);
}

export function verifyRefreshToken(refreshToken: string): { appUserId: string } {
  const decoded = jwt.verify(refreshToken, ENV.JWT_REFRESH_SECRET as string, { algorithms: ["HS256"] }) as {
    appUserId: string;
  };
  return { appUserId: decoded.appUserId };
}
