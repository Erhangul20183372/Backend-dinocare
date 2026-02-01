import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type CheckOrganizationMemberFilters = {
  organizationId: string;
  appUserId: string;
};

export class CheckOrganizationMemberConditionable extends BaseConditionable<CheckOrganizationMemberFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.app_user_organization_membership}.organization_id = <?>`,
      value: filters.organizationId,
    });

    conditions.push({
      sql: `${tables.app_user_organization_membership}.app_user_id = <?>`,
      value: filters.appUserId,
    });

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
