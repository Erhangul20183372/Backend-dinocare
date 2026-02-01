import { AllClientDevicesRow } from "../../infrastructure/rows";
import { AllClientDevicesDto, allClientDevicesSchema } from "../dtos/all-client-devices.dto";

export class AllClientsDevicesMapper {
  static toResponse(rows: AllClientDevicesRow[]): AllClientDevicesDto {
    if (rows.length === 0) throw new Error("No rows provided for mapping");

    return allClientDevicesSchema.parse({
      id: rows[0].client_id,
      teamId: rows[0].client_team_id,
      firstName: rows[0].client_first_name,
      lastName: rows[0].client_last_name,
      gender: rows[0].client_gender,
      devices: rows.map((r) => ({
        id: r.device_id,
        stickerId: r.device_sticker_id,
        serialNumber: r.device_serial_number,
        type: r.device_type_name,
        status: r.device_status,
        assignedSince: r.client_device_assignment_assigned_since,
        assignedUntil: r.client_device_assignment_assigned_until,
        assignedBy: r.client_device_assignment_assigned_by,
        unassignedBy: r.client_device_assignment_unassigned_by,
        location: r.client_device_assignment_device_location,
      })),
    });
  }
}
