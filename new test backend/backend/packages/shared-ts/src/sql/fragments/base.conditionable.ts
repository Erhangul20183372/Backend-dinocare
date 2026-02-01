export type Condition = { sql: string; value?: any };

export abstract class BaseConditionable<T extends Record<string, any>> {
  private readonly filters: Partial<T>;

  constructor(filters: Partial<T>) {
    this.filters = filters;
  }

  protected abstract getConditions(tables: Record<string, string>): Condition[];

  build(tables: Record<string, string>, startIndex = 1): { sql: string; values: any[] } {
    let paramIndex = startIndex;
    let lastIndex: number | null = null;
    const clauses: string[] = [];
    const values: any[] = [];

    for (const c of this.getConditions(tables)) {
      let sql = c.sql;

      if (c.value !== undefined) {
        let replaceIndex = 0;
        sql = sql.replace(/<\?>/g, () => {
          const valueIndex = replaceIndex++;
          lastIndex = paramIndex++;
          const v = Array.isArray(c.value) ? c.value[valueIndex] : c.value;
          values.push(v);
          return `$${lastIndex}`;
        });

        sql = sql.replace(/<#>/g, () => {
          if (lastIndex === null) throw new Error("No previous index for <#>");
          return `$${lastIndex}`;
        });
      }

      clauses.push(sql);
    }

    return {
      sql: clauses.length ? `WHERE ${clauses.join(" AND ")}` : "",
      values,
    };
  }

  protected getFilters(): Partial<T> {
    return this.filters;
  }
}
