import { TeamEntity } from "../../entities";
import { BaseSelectBuilder } from "./base-select.builder";

export class TeamSelectBuilder extends BaseSelectBuilder {
  private static schema = "team";
  private static table = "team";

  static override name = `${this.schema}.${this.table}`;
  static override columns: Record<keyof TeamEntity, string> = {
    id: `$table.id AS ${this.table}_id`,
    organization_id: `$table.organization_id AS ${this.table}_organization_id`,
    name: `$table.name AS ${this.table}_name`,
    color: `$table.color AS ${this.table}_color`,
    archived_on: `$table.archived_on AS ${this.table}_archived_on`,
    archived_by: `$table.archived_by AS ${this.table}_archived_by`,
  } as const;
}
