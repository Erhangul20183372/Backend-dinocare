import { PaginationMeta } from "../../http";

export type PaginatedModel<T> = {
  rows: T[] | T;
  pagination: PaginationMeta;
};
