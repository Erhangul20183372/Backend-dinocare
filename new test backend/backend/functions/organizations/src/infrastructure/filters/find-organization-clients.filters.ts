import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type FindAllOrganizationClientsFilters = {
  id: string;
  search?: string;
};

export class FindAllOrganizationClientsConditionable extends BaseConditionable<FindAllOrganizationClientsFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.team}.organization_id = <?>`,
      value: filters.id,
    });

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
