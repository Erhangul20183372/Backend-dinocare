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
  NODE_ENV: getEnv("NODE_ENV"),
  PORT: parseInt(getEnv("PORT", false) || "3000"),
  POSTGRES_HOST: getEnv("PG_HOST"),
  POSTGRES_PORT: parseInt(getEnv("PG_PORT", false) || "5432"),
  POSTGRES_USER: getEnv("PG_USER"),
  POSTGRES_PASSWORD: getEnv("PG_PASSWORD"),
  POSTGRES_DATABASE: getEnv("PG_DATABASE"),
  ALLOW_DEV_IMPERSONATION: (getEnv("ALLOW_DEV_IMPERSONATION", false) || "false").toLowerCase() === "true",
  DEV_IMPERSONATE_HEADER: getEnv("DEV_IMPERSONATE_HEADER", false) || "x-dev-app-user-id",
  DEV_APP_USER_ID: getEnv("DEV_APP_USER_ID", false) || "",
  JWT_ACCESS_SECRET: getEnv("JWT_ACCESS_SECRET"),
  JWT_REFRESH_SECRET: getEnv("JWT_REFRESH_SECRET"),
  JWT_ACCESS_EXPIRATION: getEnv("JWT_ACCESS_EXPIRATION", false) || "15m",
  JWT_REFRESH_EXPIRATION: getEnv("JWT_REFRESH_EXPIRATION", false) || "7d",
  SALT_ROUNDS: parseInt(getEnv("SALT_ROUNDS")),
};
