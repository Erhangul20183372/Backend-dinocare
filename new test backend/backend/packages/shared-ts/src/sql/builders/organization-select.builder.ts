import { OrganizationEntity } from "../../entities";
import { BaseSelectBuilder } from "./base-select.builder";

export class OrganizationSelectBuilder extends BaseSelectBuilder {
  private static schema = "organization";
  private static table = "organization";

  static override name = `${this.schema}.${this.table}`;
  static override columns: Record<keyof OrganizationEntity, string> = {
    id: `$table.id AS ${this.table}_id`,
    domain: `$table.domain AS ${this.table}_domain`,
    name: `$table.name AS ${this.table}_name`,
    logo_url: `$table.logo_url AS ${this.table}_logo_url`,
    archived_on: `$table.archived_on AS ${this.table}_archived_on`,
    archived_by: `$table.archived_by AS ${this.table}_archived_by`,
  } as const;
}
