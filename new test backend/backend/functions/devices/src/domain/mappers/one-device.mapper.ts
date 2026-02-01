import { OneDeviceRow } from "../../data/rows";
import { OneDeviceDto } from "../dtos";

export class OneDeviceMapper {
  static toResponse(row: OneDeviceRow): OneDeviceDto {
    return {
      deviceId: row.device_id,
      stickerId: row.device_sticker_id,
      serialNumber: row.device_serial_number,
      status: row.device_status,
      type: row.device_type_name,
    };
  }
}
