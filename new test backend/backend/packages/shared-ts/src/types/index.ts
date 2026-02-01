export enum Role {
  ADMIN = "ADMIN",
  USER = "USER",
  UNCONFIRMED_USER = "UNCONFIRMED_USER",
}

export enum AuthType {
  NONE = "NONE",
  BEARER = "BEARER",
}

export enum HttpMethod {
  POST = "POST",
  GET = "GET",
  PUT = "PUT",
  DELETE = "DELETE",
  PATCH = "PATCH",
}

export * from "./auth";
export * from "./identity";
export * from "./user";
