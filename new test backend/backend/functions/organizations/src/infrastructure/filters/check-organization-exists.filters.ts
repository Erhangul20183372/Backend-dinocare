import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type CheckOrganizationExistsFilters = {
  domain: string;
};

export class CheckOrganizationExistsConditionable extends BaseConditionable<CheckOrganizationExistsFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.organization}.domain = <?>`,
      value: filters.domain,
    });

    conditions.push({
      sql: `${tables.organization}.archived_on IS NULL`,
    });

    conditions.push({
      sql: `${tables.organization}.archived_by IS NULL`,
    });

    return conditions;
  }
}
