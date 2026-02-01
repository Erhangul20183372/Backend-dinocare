import { AppUserEntity } from "../../entities";
import { BaseSelectBuilder } from "./base-select.builder";

export class AppUserSelectBuilder extends BaseSelectBuilder {
  private static schema = "auth";
  private static table = "app_user";

  static override name = `${this.schema}.${this.table}`;
  static override columns: Record<keyof AppUserEntity, string> = {
    id: `$table.id AS ${this.table}_id`,
    identity_id: `$table.identity_id AS ${this.table}_identity_id`,
    first_name: `$table.first_name AS ${this.table}_first_name`,
    last_name: `$table.last_name AS ${this.table}_last_name`,
    archived_on: `$table.archived_on AS ${this.table}_archived_on`,
    archived_by: `$table.archived_by AS ${this.table}_archived_by`,
  } as const;
}
