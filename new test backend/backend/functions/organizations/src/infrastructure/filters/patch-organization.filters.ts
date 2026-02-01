import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type PatchOrganizationFilters = {
  id: string;
};

export class PatchOrganizationConditionable extends BaseConditionable<PatchOrganizationFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.organization}.id = <?>`,
      value: filters.id,
    });

    return conditions;
  }
}
