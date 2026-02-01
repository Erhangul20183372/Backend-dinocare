import { AllDevicesRow } from "../../data/rows";
import { AllDevicesDto } from "../dtos";

export class AllDevicesMapper {
  static toResponse(row: AllDevicesRow): AllDevicesDto {
    return {
      deviceId: row.device_id,
      stickerId: row.device_sticker_id,
      serialNumber: row.device_serial_number,
      status: row.device_status,
      type: row.device_type_name,
      location: row.client_device_assignment_device_location,
      client: row.client_id
        ? {
            id: row.client_id,
            firstName: row.client_first_name,
            lastName: row.client_last_name,
          }
        : null,
      teamId: row.team_id,
    };
  }
}
