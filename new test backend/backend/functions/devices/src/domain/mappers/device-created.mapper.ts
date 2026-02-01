import { DeviceCreatedRow } from "../../data/rows";
import { DeviceCreatedDto } from "../dtos";

export class DeviceCreatedMapper {
  static toResponse(row: DeviceCreatedRow): DeviceCreatedDto {
    return {
      deviceId: row.device_id,
      stickerId: row.device_sticker_id,
      serialNumber: row.device_serial_number,
      status: row.device_status,
      typeId: row.device_device_type_id,
    };
  }
}
