import { OrganizationRole, TeamRole } from "@shared/ts/entities";
import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type GetUsersFilter = {
  teamId?: string;
  teamRole?: TeamRole;
  organizationId?: string;
  organizationRole?: OrganizationRole;
  search?: string;
};

export class GetLimitedUsersConditionable extends BaseConditionable<GetUsersFilter> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    if (filters.search) {
      conditions.push({
        sql: `(
          LOWER(${tables.app_user}.first_name) LIKE LOWER('%' || <?> || '%')
          OR LOWER(${tables.app_user}.last_name) LIKE LOWER('%' || <#> || '%')
          OR LOWER(${tables.app_user}.first_name || ' ' || ${tables.app_user}.last_name) LIKE LOWER('%' || <#> || '%')
        )`,
        value: filters.search,
      });
    }

    conditions.push({
      sql: `${tables.app_user}.archived_on IS NULL`,
    });

    conditions.push({
      sql: `${tables.app_user}.archived_by IS NULL`,
    });

    return conditions;
  }
}

export class GetUsersAdditionsConditionable extends BaseConditionable<GetUsersFilter> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    if (filters.teamId) {
      conditions.push({
        sql: `${tables.app_user_team_membership}.team_id = <?>`,
        value: filters.teamId,
      });
    }

    if (filters.teamRole) {
      conditions.push({
        sql: `${tables.app_user_team_membership}.role = <?>`,
        value: filters.teamRole,
      });
    }

    conditions.push({
      sql: `${tables.app_user_team_membership}.archived_on IS NULL`,
    });

    conditions.push({
      sql: `${tables.app_user_team_membership}.archived_by IS NULL`,
    });

    conditions.push({
      sql: `${tables.app_user_team_membership}.member_until IS NULL`,
    });

    if (filters.organizationId) {
      conditions.push({
        sql: `${tables.app_user_organization_membership}.organization_id = <?>`,
        value: filters.organizationId,
      });
    }

    if (filters.organizationRole) {
      conditions.push({
        sql: `${tables.app_user_organization_membership}.role = <?>`,
        value: filters.organizationRole,
      });
    }

    conditions.push({
      sql: `${tables.app_user_organization_membership}.archived_on IS NULL`,
    });

    conditions.push({
      sql: `${tables.app_user_organization_membership}.archived_by IS NULL`,
    });

    conditions.push({
      sql: `${tables.app_user_organization_membership}.member_until IS NULL`,
    });

    return conditions;
  }
}
