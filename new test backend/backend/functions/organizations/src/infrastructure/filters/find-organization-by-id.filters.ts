import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type FindOrganizationByIdFilters = {
  id: string;
};

export class FindOrganizationByIdConditionable extends BaseConditionable<FindOrganizationByIdFilters> {
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
