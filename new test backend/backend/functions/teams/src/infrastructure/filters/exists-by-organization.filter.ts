import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type ExistsByOrganizationFilters = {
  organizationId: string;
  name: string;
  excludeTeamId?: string;
};

export class ExistsByOrganizationConditionable extends BaseConditionable<ExistsByOrganizationFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    if (filters.organizationId) {
      conditions.push({
        sql: `${tables.team}.organization_id = <?>`,
        value: filters.organizationId,
      });
    }

    if (filters.name) {
      conditions.push({
        sql: `LOWER(${tables.team}.name) = LOWER(<?>)`,
        value: filters.name,
      });
    }

    if (filters.excludeTeamId) {
      conditions.push({
        sql: `${tables.team}.id != <?>`,
        value: filters.excludeTeamId,
      });
    }

    return conditions;
  }
}
