export interface DeviceEntity {
  id: string;
  sticker_id: string;
  serial_number: string;
  device_type_id: string;
  status: "active" | "inactive" | "retired" | "in_repair";
}
