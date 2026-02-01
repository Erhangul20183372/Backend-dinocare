import { DeviceStatus } from "@shared/ts/entities";
import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type GetAllDevicesFilter = {
  organizationId?: string;
  teamId?: string;
  clientId?: string;
  type?: string;
  status?: DeviceStatus;
  search?: string;
};

export class GetAllDevicesConditionable extends BaseConditionable<GetAllDevicesFilter> {
  protected getConditions(tables: Record<string, string>): Condition[] {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    if (filters.organizationId) {
      conditions.push({
        sql: `${tables.team}.organization_id = <?>`,
        value: filters.organizationId,
      });
    }

    if (filters.teamId) {
      conditions.push({
        sql: `${tables.client}.team_id = <?>`,
        value: filters.teamId,
      });
    }

    if (filters.clientId) {
      conditions.push({
        sql: `${tables.client_device_assignment}.client_id = <?>`,
        value: filters.clientId,
      });
    }

    if (filters.type) {
      conditions.push({
        sql: `${tables.device_type}.name = <?>`,
        value: filters.type,
      });
    }

    if (filters.status) {
      conditions.push({
        sql: `${tables.device}.status = <?>`,
        value: filters.status,
      });
    }

    if (filters.search) {
      conditions.push({
        sql: `(
          LOWER(${tables.client}.first_name) LIKE LOWER('%' || <?> || '%')
          OR LOWER(${tables.client}.last_name) LIKE LOWER('%' || <#> || '%')
          OR LOWER(${tables.client}.first_name || ' ' || ${tables.client}.last_name) LIKE LOWER('%' || <#> || '%')
        )`,
        value: filters.search,
      });
    }

    return conditions;
  }
}
