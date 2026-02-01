import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type DeleteClientFilters = {
  id: string;
};

export class DeleteClientConditionable extends BaseConditionable<DeleteClientFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.client}.id = <?>`,
      value: filters.id,
    });

    conditions.push({
      sql: `${tables.client}.archived_on IS NULL`,
    });

    conditions.push({
      sql: `${tables.client}.archived_by IS NULL`,
    });

    return conditions;
  }
}
