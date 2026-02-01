export type Pagination = {
  limit: number;
  offset: number;
};

export class Paginatable {
  build(pagination: Pagination, startIndex = 1) {
    return {
      sql: `LIMIT $${startIndex} OFFSET $${startIndex + 1}`,
      values: [pagination.limit, pagination.offset],
    };
  }
}
