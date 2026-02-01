export interface TotalRow {
  total: number;
}

export function extractTotal(result: { rows: TotalRow[] }): number {
  return result.rows[0]?.total != null ? Number(result.rows[0].total) : 0;
}
