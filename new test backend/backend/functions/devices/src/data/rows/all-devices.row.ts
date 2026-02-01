import { DeviceStatus } from "@shared/ts/entities";

export interface AllDevicesRow {
  device_id: string;
  device_sticker_id: string;
  device_serial_number: string;
  device_status: DeviceStatus;
  device_type_name: string;
  client_device_assignment_device_location: string;
  client_first_name: string;
  client_last_name: string;
  client_id: string;
  team_id: string;
}
