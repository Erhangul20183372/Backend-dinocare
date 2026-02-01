import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type CheckClientDeviceFilters = {
  clientId: string;
  deviceId: string;
};

export class CheckClientDeviceConditionable extends BaseConditionable<CheckClientDeviceFilters> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `${tables.clientDeviceAssignment}.client_id = <?>`,
      value: filters.clientId,
    });

    conditions.push({
      sql: `${tables.clientDeviceAssignment}.device_id = <?>`,
      value: filters.deviceId,
    });

    conditions.push({
      sql: `${tables.clientDeviceAssignment}.assigned_until IS NULL`,
    });

    conditions.push({
      sql: `${tables.clientDeviceAssignment}.unassigned_by IS NULL`,
    });

    return conditions;
  }
}
