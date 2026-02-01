import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type PatchClientFilters = {
  id: string;
};
export class PatchClientConditionable extends BaseConditionable<PatchClientFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.client}.id = <?>`,
      value: filters.id,
    });

    return conditions;
  }
}
