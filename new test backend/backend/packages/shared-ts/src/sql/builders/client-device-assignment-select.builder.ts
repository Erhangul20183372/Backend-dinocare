import { ClientDeviceAssignmentEntity } from "../../entities";
import { BaseSelectBuilder } from "./base-select.builder";

export class ClientDeviceAssignmentSelectBuilder extends BaseSelectBuilder {
  private static schema = "device";
  private static table = "client_device_assignment";

  static override name = `${this.schema}.${this.table}`;
  static override columns: Record<keyof ClientDeviceAssignmentEntity, string> = {
    client_id: `$table.client_id AS ${this.table}_client_id`,
    device_id: `$table.device_id AS ${this.table}_device_id`,
    assigned_since: `$table.assigned_since AS ${this.table}_assigned_since`,
    assigned_until: `$table.assigned_until AS ${this.table}_assigned_until`,
    assigned_by: `$table.assigned_by AS ${this.table}_assigned_by`,
    unassigned_by: `$table.unassigned_by AS ${this.table}_unassigned_by`,
    device_location: `$table.device_location AS ${this.table}_device_location`,
  } as const;
}
