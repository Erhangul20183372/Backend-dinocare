import { DeviceStatus } from "@shared/ts/entities";

export interface OneDeviceRow {
  device_id: string;
  device_sticker_id: string;
  device_serial_number: string;
  device_status: DeviceStatus;
  device_type_name: string;
}
