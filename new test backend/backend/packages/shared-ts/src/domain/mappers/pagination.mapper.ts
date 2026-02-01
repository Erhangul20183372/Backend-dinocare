import { PaginationMeta } from "../../http/responses/response.base";

export function toPaginationMeta(args: {
  total: number;
  count: number;
  limit: number;
  offset: number;
}): PaginationMeta {
  const { limit, offset, count, total } = args;

  const hasNextPage = offset + count < total;
  const hasPreviousPage = offset > 0;

  return { limit, offset, count, total, hasNextPage, hasPreviousPage } as PaginationMeta;
}
