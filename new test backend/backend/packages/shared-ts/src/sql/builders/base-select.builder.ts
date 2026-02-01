export abstract class BaseSelectBuilder {
  static columns: Record<string, string>;
  static name: string;

  static bind<TColumns extends Record<string, string>>(
    this: {
      columns: TColumns;
      name: string;
    },
    alias: string
  ) {
    type Keys = keyof TColumns & string;

    const resolveFields = (fields?: "*" | { include: Keys[] } | { exclude: Keys[] }): Keys[] => {
      const all = Object.keys(this.columns) as Keys[];
      if (!fields || fields === "*") return all;
      if ("include" in fields) return fields.include;
      if ("exclude" in fields) return all.filter((f) => !fields.exclude.includes(f));
      return all;
    };

    return {
      select: (fields?: "*" | { include: Keys[] } | { exclude: Keys[] }) =>
        resolveFields(fields)
          .map((f) => this.columns[f].replace(/\$table/g, alias))
          .join(", "),

      returning: (fields?: "*" | { include: Keys[] } | { exclude: Keys[] }) =>
        resolveFields(fields)
          .map((f) => this.columns[f].replace(/\$table\./, ""))
          .join(", "),

      ref: (column: Keys) => `${alias}.${column}`,
      alias,
      name: this.name,
    };
  }
}
