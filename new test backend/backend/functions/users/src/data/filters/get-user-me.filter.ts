import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export class GetUserMeConditionable extends BaseConditionable<{}> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.app_user}.id = current_setting('app.current_user_id', true)::uuid`,
    });

    return conditions;
  }
}
