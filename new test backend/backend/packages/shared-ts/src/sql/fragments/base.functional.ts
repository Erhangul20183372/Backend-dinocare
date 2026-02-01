export abstract class BaseFunctional<TArgs extends Record<string, any>> {
  protected readonly input: TArgs;
  protected abstract name: string;
  protected abstract returns: string[];
  protected abstract readonly returnType: "TABLE" | "VALUE";

  constructor(input: TArgs) {
    this.input = input;
  }

  build(): { sql: string; values: any[] } {
    const keys = Object.keys(this.input);
    const values = Object.values(this.input);
    const placeholders = keys.map((_, i) => `$${i + 1}`).join(", ");
    const returnCols = this.returns.length > 0 ? this.returns.join(", ") : "*";

    let sql: string;
    switch (this.returnType) {
      case "VALUE":
        sql = `SELECT ${this.name}(${placeholders}) AS ${returnCols};`;
        break;
      case "TABLE":
        sql = `SELECT ${returnCols} FROM ${this.name}(${placeholders});`;
        break;
      default:
        throw new Error(`Unsupported returnType: ${this.returnType}`);
    }

    return { sql: sql.trim(), values };
  }
}
