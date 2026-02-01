import * as dotenv from "dotenv";

dotenv.config();
dotenv.config({ path: ".env.local", override: true });

function getEnv(key: string, required = true): string {
  const value = process.env[key];
  if (required && !value) {
    throw new Error(`Missing environment variable: ${key}`);
  }
  return value as string;
}

export const ENV = {
  NODE_ENV: getEnv("NODE_ENV", false) || "development",
  JWT_ACCESS_SECRET: getEnv("JWT_ACCESS_SECRET"),
  ALLOW_DEV_IMPERSONATION: (getEnv("ALLOW_DEV_IMPERSONATION", false) || "false").toLowerCase() === "true",
  DEV_IMPERSONATE_HEADER: getEnv("DEV_IMPERSONATE_HEADER", false) || "x-dev-app-user-id",
  DEV_APP_USER_ID: getEnv("DEV_APP_USER_ID", false) || "",
};
