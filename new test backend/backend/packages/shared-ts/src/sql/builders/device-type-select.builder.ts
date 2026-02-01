import { DeviceTypeEntity } from "../../entities";
import { BaseSelectBuilder } from "./base-select.builder";

export class DeviceTypeSelectBuilder extends BaseSelectBuilder {
  private static schema = "device";
  private static table = "device_type";

  static override name = `${this.schema}.${this.table}`;
  static override columns: Record<keyof DeviceTypeEntity, string> = {
    id: `$table.id AS ${this.table}_id`,
    name: `$table.name AS ${this.table}_name`,
  } as const;
}
