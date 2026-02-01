import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type CreateOrganizationMemberFilters = {
  id: string;
};

export class CreateOrganizationMemberConditionable extends BaseConditionable<CreateOrganizationMemberFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.app_user_organization_membership}.id = <?>`,
      value: filters.id,
    });

    return conditions;
  }
}
