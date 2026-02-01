import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type FindAllFilters = {
  organizationId?: string;
  teamId?: string;
  clientStatus?: "active" | "inactive";
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

    if (filters.teamId) {
      conditions.push({
        sql: `${tables.client}.team_id = <?>`,
        value: filters.teamId,
      });
    }

    if (filters.clientStatus === "active") {
      conditions.push({ sql: `${tables.client}.archived_on IS NULL` });
    }

    if (filters.clientStatus === "inactive") {
      conditions.push({ sql: `${tables.client}.archived_on IS NOT NULL` });
    }

    if (filters.search) {
      conditions.push({
        sql: `(
          LOWER(${tables.client}.first_name) LIKE LOWER('%' || <?> || '%')
          OR LOWER(${tables.client}.last_name) LIKE LOWER('%' || <#> || '%')
          OR LOWER(${tables.client}.first_name || ' ' || ${tables.client}.last_name) LIKE LOWER('%' || <#> || '%')
        )`,
        value: filters.search,
      });
    }

    return conditions;
  }
}
