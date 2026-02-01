import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type FindByIdFilters = {
  teamId: string;
};

export class FindByIdConditionable extends BaseConditionable<FindByIdFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    if (filters.teamId) {
      conditions.push({
        sql: `${tables.team}.id = <?>`,
        value: filters.teamId,
      });
    }

    conditions.push({
      sql: `${tables.team}.archived_on IS NULL`,
    });
    conditions.push({
      sql: `${tables.team}.archived_by IS NULL`,
    });

    return conditions;
  }
}
