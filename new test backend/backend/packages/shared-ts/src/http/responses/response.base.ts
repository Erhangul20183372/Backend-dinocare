import type { Request } from "express";
import { ResponseCode } from "./response.code";

export type HttpResponseArgs<T> = {
  status: number;
  code: ResponseCode;
  data: T | null;
  req: Request;
  pagination?: PaginationMeta;
};

export interface PaginationMeta {
  limit: number;
  offset: number;
  count: number;
  total: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
}

export class HttpResponse<T> {
  public readonly status: number;
  public readonly code: ResponseCode;
  public readonly data: T | null;
  public readonly timestamp: string;
  public readonly pagination?: PaginationMeta;

  constructor({ status, code, data, pagination }: Omit<HttpResponseArgs<T>, "req">) {
    this.status = status;
    this.code = code;
    this.data = data;
    this.timestamp = new Date().toISOString();
    this.pagination = pagination;
  }

  toJSON() {
    return {
      status: this.status,
      code: this.code,
      data: this.data,
      timestamp: this.timestamp,
      pagination: this.pagination,
    };
  }

  toString(): string {
    throw new Error("Use .toJSON() to serialize HttpResponse safely.");
  }
}
