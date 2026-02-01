import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type FindAllFilters = {
  organizationId?: string;
  search?: string;
};

export class FindAllConditionable extends BaseConditionable<FindAllFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    if (filters.organizationId) {
      conditions.push({
        sql: `${tables.team}.organization_id = <?>`,
        value: filters.organizationId,
      });
    }

    if (filters.search) {
      conditions.push({
        sql: `LOWER(${tables.team}.name) LIKE LOWER('%' || <?> || '%')`,
        value: filters.search,
      });
    }

    conditions.push({
      sql: `${tables.team}.archived_on IS NULL`,
    });
    conditions.push({
      sql: `${tables.team}.archived_by IS NULL`,
    });

    return conditions;
  }
}
