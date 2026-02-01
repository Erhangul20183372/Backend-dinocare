export enum ErrorType {
  APP_USER_ID_NOT_SET = "APP_USER_ID_NOT_SET",
  ORGANIZATION_NOT_FOUND = "ORGANIZATION_NOT_FOUND",
  ORGANIZATION_ALREADY_EXISTS = "ORGANIZATION_ALREADY_EXISTS",
  ENDPOINT_NOT_FOUND = "ENDPOINT_NOT_FOUND",
  METHOD_NOT_ALLOWED = "METHOD_NOT_ALLOWED",
  VALIDATION_FAILED = "VALIDATION_FAILED",
  DEVICE_NOT_FOUND = "DEVICE_NOT_FOUND",
  HUB_NOT_FOUND = "HUB_NOT_FOUND",
  HUB_ALREADY_REGISTERED = "HUB_ALREADY_REGISTERED",
  DEVICE_ALREADY_REGISTERED = "DEVICE_ALREADY_REGISTERED",
  USER_NOT_FOUND = "USER_NOT_FOUND",
  CLIENT_NOT_FOUND = "CLIENT_NOT_FOUND",
  USER_ALREADY_EXISTS = "USER_ALREADY_EXISTS",
  INTERNAL_SERVER_ERROR = "INTERNAL_SERVER_ERROR",
  INVALID_CREDENTIALS = "INVALID_CREDENTIALS",
  INVALID_BEARER_TOKEN = "INVALID_BEARER_TOKEN",
  INVALID_REFRESH_TOKEN = "INVALID_REFRESH_TOKEN",
  BEARER_TOKEN_REQUIRED = "BEARER_TOKEN_REQUIRED",
  CLIENT_CERTIFICATE_REQUIRED = "CLIENT_CERTIFICATE_REQUIRED",
  CLIENT_CERTIFICATE_INVALID = "CLIENT_CERTIFICATE_INVALID",
  INSUFFICIENT_PERMISSIONS = "INSUFFICIENT_PERMISSIONS",
  DEVICE_UPDATE_FAILED = "DEVICE_UPDATE_FAILED",
  ALERT_NOT_FOUND = "ALERT_NOT_FOUND",
  TEAM_ALREADY_EXISTS = "TEAM_ALREADY_EXISTS",
  TEAM_NOT_FOUND = "TEAM_NOT_FOUND",
  USER_ALREADY_INVITED = "USER_ALREADY_INVITED",
  USER_ALREADY_MEMBER_OF_TEAM = "USER_ALREADY_MEMBER_OF_TEAM",
  USER_NOT_MEMBER_OF_TEAM = "USER_NOT_MEMBER_OF_TEAM",
  MEMBERSHIP_NOT_FOUND = "MEMBERSHIP_NOT_FOUND",
}

export class HttpError extends Error {
  public readonly statusCode: number;
  public readonly errorType: string;
  public readonly errors: any;

  constructor(statusCode: number, errorType: string, message?: string, errors?: any, stack?: string) {
    super(message);
    this.statusCode = statusCode;
    this.errorType = errorType;
    this.errors = errors;
    this.stack = stack;
    Object.setPrototypeOf(this, new.target.prototype);
  }

  toJSON(): {
    errorType: string;
    message: string;
    errors?: unknown;
    stack?: string;
  } {
    const json = {
      errorType: this.errorType,
      message: this.message,
      errors: this.errors,
    };
    return process.env.NODE_ENV === "development" ? { ...json, stack: this.stack } : json;
  }
}

export class InternalServerError extends HttpError {
  constructor(message?: string) {
    super(500, ErrorType.INTERNAL_SERVER_ERROR, message);
  }
}

export class BadRequestError extends HttpError {
  constructor(errorType: ErrorType, message?: string) {
    super(400, errorType, message);
  }
}

export class NotFoundError extends HttpError {
  constructor(errorType: ErrorType, message: string = "Resource not found") {
    super(404, errorType, message);
  }
}

export class UnauthorizedError extends HttpError {
  constructor(errorType: ErrorType, message?: string) {
    super(401, errorType, message);
  }
}

export class ForbiddenError extends HttpError {
  constructor(errorType: ErrorType, message?: string) {
    super(403, errorType, message);
  }
}

export class ConflictError extends HttpError {
  constructor(errorType: ErrorType, message?: string) {
    super(409, errorType, message);
  }
}

export class EndpointNotFoundError extends HttpError {
  constructor(method: string, url: string) {
    super(404, ErrorType.ENDPOINT_NOT_FOUND, `No endpoint matched your request: ${method} ${url}`);
  }
}

export class EndpointMethodNotAllowed extends HttpError {
  constructor(method: string, url: string) {
    super(405, ErrorType.METHOD_NOT_ALLOWED, `Method not allowed for this endpoint: ${method} ${url}`);
  }
}

export class ValidationError extends HttpError {
  constructor(issues: Array<{ message: string; path: (string | number)[] }>, location: string) {
    const errorDetails = issues.map((issue) => ({
      message: issue.message,
      parameter: issue.path.at(-1),
      location,
    }));
    super(400, ErrorType.VALIDATION_FAILED, "Validation failed", errorDetails);
  }
}

export class NotImplementedError extends HttpError {
  constructor(message?: string) {
    super(501, "NOT_IMPLEMENTED", message || "This functionality is not implemented.");
  }
}
