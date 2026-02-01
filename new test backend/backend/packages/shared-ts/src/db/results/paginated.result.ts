export type PaginatedResult<T> = {
  rows: T[];
  total: number;
  count: number;
  limit: number;
  offset: number;
};
