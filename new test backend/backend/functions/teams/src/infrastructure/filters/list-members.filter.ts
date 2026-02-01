import { TeamRole } from "@shared/ts/entities";
import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type ListMembersFilters = {
  teamId: string;
  role?: TeamRole;
};

export class ListMembersConditionable extends BaseConditionable<ListMembersFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    if (filters.teamId) {
      conditions.push({
        sql: `${tables.app_user_team_membership}.team_id = <?>`,
        value: filters.teamId,
      });
    }

    if (filters.role) {
      conditions.push({
        sql: `${tables.app_user_team_membership}.role = <?>`,
        value: filters.role,
      });
    }

    conditions.push({
      sql: `${tables.app_user_team_membership}.member_until IS NULL`,
    });

    conditions.push({
      sql: `${tables.app_user_team_membership}.archived_on IS NULL`,
    });

    return conditions;
  }
}
