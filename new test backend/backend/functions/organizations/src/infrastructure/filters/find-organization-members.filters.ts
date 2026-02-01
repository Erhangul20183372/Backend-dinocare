import { OrganizationRole } from "@shared/ts/entities";
import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type FindAllOrganizationMembersFilters = {
  organizationId: string;
  role?: OrganizationRole;
};

export class FindAllOrganizationMembersConditionable extends BaseConditionable<FindAllOrganizationMembersFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.app_user_organization_membership}.organization_id = <?>`,
      value: filters.organizationId,
    });

    if (filters.role) {
      conditions.push({
        sql: `${tables.app_user_organization_membership}.role = <?>`,
        value: filters.role,
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
