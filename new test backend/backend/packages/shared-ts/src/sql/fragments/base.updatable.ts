export abstract class BaseUpdatable<T extends Record<string, any>> {
  protected abstract mapping: Record<keyof T, string>;
  protected readonly fields: Partial<T>;
  protected expressions: Record<string, string> = {};

  constructor(fields: Partial<T>) {
    this.fields = fields;
  }

  addExpression(column: string, expression: string): this {
    this.expressions[column] = expression;
    return this;
  }

  build(startIndex = 1): { sql: string; values: any[] } {
    const keys = (Object.keys(this.fields) as (keyof T)[]).filter((k) => this.fields[k] !== undefined);

    const assignments: string[] = [];
    const values: any[] = [];

    keys.forEach((k, i) => {
      assignments.push(`${this.mapping[k]} = $${startIndex + i}`);
      values.push(this.fields[k]!);
    });

    for (const [col, expr] of Object.entries(this.expressions)) {
      assignments.push(`${col} = ${expr}`);
    }

    return {
      sql: assignments.join(", "),
      values,
    };
  }
}
