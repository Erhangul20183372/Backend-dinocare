import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type GetDeviceByIdFilter = {
  id: string;
};

export class GetDeviceByIdConditionable extends BaseConditionable<GetDeviceByIdFilter> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    if (filters.id) {
      conditions.push({
        sql: `${tables.device}.id = <?>`,
        value: filters.id,
      });
    }

    return conditions;
  }
}
