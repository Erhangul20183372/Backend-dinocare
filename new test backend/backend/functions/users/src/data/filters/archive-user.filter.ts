import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type ArchiveUserFilter = {
  id: string;
};

export class ArchiveUserConditionable extends BaseConditionable<ArchiveUserFilter> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.app_user}.id = <?>`,
      value: filters.id,
    });

    conditions.push({
      sql: `${tables.app_user}.archived_on IS NULL`,
    });

    conditions.push({
      sql: `${tables.app_user}.archived_by IS NULL`,
    });

    return conditions;
  }
}
