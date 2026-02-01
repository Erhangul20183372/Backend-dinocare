import { ClientEntity } from "../../entities";
import { BaseSelectBuilder } from "./base-select.builder";

export class ClientSelectBuilder extends BaseSelectBuilder {
  private static schema = "client";
  private static table = "client";

  static override name = `${this.schema}.${this.table}`;
  static override columns: Record<keyof ClientEntity, string> = {
    id: `$table.id AS ${this.table}_id`,
    team_id: `$table.team_id AS ${this.table}_team_id`,
    first_name: `$table.first_name AS ${this.table}_first_name`,
    last_name: `$table.last_name AS ${this.table}_last_name`,
    gender: `$table.gender AS ${this.table}_gender`,
    archived_on: `$table.archived_on AS ${this.table}_archived_on`,
    archived_by: `$table.archived_by AS ${this.table}_archived_by`,
  } as const;
}
