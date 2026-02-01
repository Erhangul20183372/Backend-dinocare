import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type DeleteOrganizationMemberFilters = {
  organizationId: string;
  appUserId: string;
};

export class DeleteOrganizationMemberConditionable extends BaseConditionable<DeleteOrganizationMemberFilters> {
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

    return conditions;
  }
}
