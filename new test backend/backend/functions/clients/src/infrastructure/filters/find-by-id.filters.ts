import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type FindByIdFilters = {
  id: string;
};

export class FindByIdConditionable extends BaseConditionable<FindByIdFilters> {
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
