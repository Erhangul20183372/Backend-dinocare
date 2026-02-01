import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type DeleteOrganizationFilters = {
  id: string;
};

export class DeleteOrganizationConditionable extends BaseConditionable<DeleteOrganizationFilters> {
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
