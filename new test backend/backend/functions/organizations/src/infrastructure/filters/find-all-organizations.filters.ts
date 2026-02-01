import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export class FindAllOrganizationsConditionable extends BaseConditionable<{}> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.organization}.archived_on IS NULL`,
    });

    conditions.push({
      sql: `${tables.organization}.archived_by IS NULL`,
    });

    return conditions;
  }
}
