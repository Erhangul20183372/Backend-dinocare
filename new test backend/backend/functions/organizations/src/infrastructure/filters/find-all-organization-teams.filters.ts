import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type FindAllOrganizationTeamsFilters = {
  id: string;
  search?: string;
};

export class FindAllOrganizationTeamsConditionable extends BaseConditionable<FindAllOrganizationTeamsFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.team}.organization_id = <?>`,
      value: filters.id,
    });

    if (filters.search) {
      conditions.push({
        sql: `LOWER(${tables.team}.name) LIKE LOWER('%' || <?> || '%')`,
        value: filters.search,
      });
    }

    return conditions;
  }
}
