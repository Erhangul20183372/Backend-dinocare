export abstract class BaseInsertable<T extends Record<string, any>> {
  protected abstract mapping: Record<keyof T, string>;
  protected readonly inputs: T[];
  protected expressions: Record<string, string> = {};

  constructor(input: T | T[]) {
    this.inputs = Array.isArray(input) ? input : [input];
  }

  addExpression(column: string, expression: string): this {
    this.expressions[column] = expression;
    return this;
  }

  build(startIndex = 1): { sql: string; values: any[] } {
    if (this.inputs.length === 0) {
      throw new Error("No inputs provided for insert");
    }

    const keys = Object.keys(this.mapping) as (keyof T)[];
    const inputColumns = keys.map((k) => this.mapping[k]);

    const exprColumns = Object.keys(this.expressions);
    const exprValues = Object.values(this.expressions);

    const allColumns = [...inputColumns, ...exprColumns].join(", ");

    const values: any[] = [];
    const rows = this.inputs.map((row, rowIndex) => {
      const placeholders = keys.map((_, colIndex) => `$${rowIndex * keys.length + colIndex + startIndex}`);
      keys.forEach((k) => values.push(row[k]));
      return `(${[...placeholders, ...exprValues].join(", ")})`;
    });

    return {
      sql: `(${allColumns}) VALUES ${rows.join(", ")}`,
      values,
    };
  }
}
