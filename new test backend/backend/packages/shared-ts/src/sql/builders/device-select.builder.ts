import { DeviceEntity } from "@shared/ts/entities";
import { BaseSelectBuilder } from "./base-select.builder";

export class DeviceSelectBuilder extends BaseSelectBuilder {
  private static schema = "device";
  private static table = "device";

  static override name = `${this.schema}.${this.table}`;
  static override columns: Record<keyof DeviceEntity, string> = {
    id: `$table.id AS ${this.table}_id`,
    sticker_id: `$table.sticker_id AS ${this.table}_sticker_id`,
    serial_number: `$table.serial_number AS ${this.table}_serial_number`,
    device_type_id: `$table.device_type_id AS ${this.table}_device_type_id`,
    status: `$table.status AS ${this.table}_status`,
  } as const;
}
