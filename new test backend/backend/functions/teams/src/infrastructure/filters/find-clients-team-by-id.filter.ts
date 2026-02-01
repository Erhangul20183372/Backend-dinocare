import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type FindClientsTeamByIdFilters = {
  teamId: string;
  search?: string;
};

export class FindClientsTeamByIdConditionable extends BaseConditionable<FindClientsTeamByIdFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.client}.team_id = <?>`,
      value: filters.teamId,
    });

    conditions.push({
      sql: `${tables.client}.archived_on IS NULL`,
    });
    conditions.push({
      sql: `${tables.client}.archived_by IS NULL`,
    });

    if (filters.search) {
      conditions.push({
        sql: `(${tables.client}.first_name ILIKE <?} OR ${tables.client}.last_name ILIKE <?)`,
        value: `%${filters.search}%`,
      });
    }

    return conditions;
  }
}
