import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type PatchDeviceFilters = {
  id: string;
};

export class PatchDeviceConditionable extends BaseConditionable<PatchDeviceFilters> {
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
