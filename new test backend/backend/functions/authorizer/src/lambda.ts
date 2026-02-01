import jwt from "jsonwebtoken";
import { ENV } from "./env";

type SimpleAuthorizerResponse = {
  isAuthorized: boolean;
  context?: Record<string, string | number | boolean>;
  principalId?: string;
};

export const handler = async (event: any): Promise<SimpleAuthorizerResponse> => {
  try {
    const impersonatedUserId = getImpersonatedUserId(event);
    if (impersonatedUserId) return buildAuthorizedResponse(impersonatedUserId);

    const token = extractToken(event);
    if (!token) return { isAuthorized: false };

    const { appUserId } = jwt.verify(token, ENV.JWT_ACCESS_SECRET as string, { algorithms: ["HS256"] }) as {
      appUserId?: string | number;
    };
    if (!appUserId) return { isAuthorized: false };

    return buildAuthorizedResponse(String(appUserId));
  } catch (error) {
    return { isAuthorized: false };
  }
};

function buildAuthorizedResponse(appUserId: string): SimpleAuthorizerResponse {
  const id = appUserId.trim();
  return {
    isAuthorized: true,
    principalId: id,
    context: { appUserId: id },
  };
}

function extractToken(event: any): string | null {
  // Prefer Authorization header
  const headers = event?.headers || {};
  const headerVal: string = headers.authorization || headers.Authorization || "";
  if (headerVal) {
    const match = /Bearer\s+(.+)/i.exec(headerVal);
    if (match && match[1]) return match[1].trim();
    // Fallback: raw token in header
    if (!headerVal.toLowerCase().startsWith("bearer")) return headerVal.trim();
  }

  // Fallback to identitySource if configured
  if (Array.isArray(event?.identitySource) && event.identitySource.length > 0) {
    const src = String(event.identitySource[0]);
    const match = /Bearer\s+(.+)/i.exec(src);
    return match && match[1] ? match[1].trim() : src.trim();
  }

  return null;
}

function getHeaderValue(headers: Record<string, unknown> | undefined, name: string): string | null {
  if (!headers) return null;
  const target = name.toLowerCase();
  for (const [key, rawValue] of Object.entries(headers)) {
    if (!key || key.toLowerCase() !== target || rawValue == null) continue;
    const value = Array.isArray(rawValue) ? rawValue[0] : rawValue;
    const text = String(value).trim();
    if (text) return text;
  }
  return null;
}

function getImpersonatedUserId(event: any): string | null {
  const devImpersonationEnabled = ENV.NODE_ENV === "development" && ENV.ALLOW_DEV_IMPERSONATION;
  if (!devImpersonationEnabled) return null;

  const headerName = ENV.DEV_IMPERSONATE_HEADER?.trim();
  const fromHeader = headerName ? getHeaderValue(event?.headers, headerName) : null;
  const staticId = ENV.DEV_APP_USER_ID?.trim();
  const appUserId = fromHeader || staticId || null;
  return appUserId && appUserId.length > 0 ? appUserId : null;
}
