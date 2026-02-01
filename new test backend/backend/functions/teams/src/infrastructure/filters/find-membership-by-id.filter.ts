import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type FindMembershipByIdFilters = {
  teamId: string;
  userId: string;
};

export class FindMembershipByIdConditionable extends BaseConditionable<FindMembershipByIdFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.app_user_team_membership}.team_id = <?>`,
      value: filters.teamId,
    });

    conditions.push({
      sql: `${tables.app_user_team_membership}.app_user_id = <?>`,
      value: filters.userId,
    });

    conditions.push({
      sql: `${tables.app_user_team_membership}.archived_on IS NULL`,
    });
    conditions.push({
      sql: `${tables.app_user_team_membership}.archived_by IS NULL`,
    });

    return conditions;
  }
}
