import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type FindAllDevicesFilters = {
  id: string;
};

export class FindAllDevicesConditionable extends BaseConditionable<FindAllDevicesFilters> {
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
