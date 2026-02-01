import { DevicePatchedRow } from "../../data/rows";
import { DevicePatchedDto } from "../dtos";

export class DevicePatchedMapper {
  static toResponse(row: DevicePatchedRow): DevicePatchedDto {
    return {
      deviceId: row.device_id,
      stickerId: row.device_sticker_id,
      serialNumber: row.device_serial_number,
      status: row.device_status,
      typeId: row.device_device_type_id,
    };
  }
}
