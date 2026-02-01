import { ClientDeviceDeletedRow } from "../../infrastructure/rows";
import { ClientDeviceDeletedDto, clientDeviceDeletedSchema } from "../dtos/client-device-deleted.dto";

export class ClientDeviceDeletedMapper {
  static toResponse(r: ClientDeviceDeletedRow): ClientDeviceDeletedDto {
    return clientDeviceDeletedSchema.parse({
      clientId: r.client_device_assignment_client_id,
      deviceId: r.client_device_assignment_device_id,
      location: r.client_device_assignment_device_location,
      assignedBy: r.client_device_assignment_assigned_by,
      assignedSince: r.client_device_assignment_assigned_since,
      assignedUntil: r.client_device_assignment_assigned_until,
      unassignedBy: r.client_device_assignment_unassigned_by,
    });
  }
}
