import { IdentityEntity } from "../../entities";
import { BaseSelectBuilder } from "./base-select.builder";

export class IdentitySelectBuilder extends BaseSelectBuilder {
  private static schema = "auth";
  private static table = "identity";

  static override name = `${this.schema}.${this.table}`;
  static override columns: Record<keyof IdentityEntity, string> = {
    id: `$table.id AS ${this.table}_id`,
    email_address: `$table.email_address AS ${this.table}_email_address`,
    password_hash: `$table.password_hash AS ${this.table}_password_hash`,
  } as const;
}
