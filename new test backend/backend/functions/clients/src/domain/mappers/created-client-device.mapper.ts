import { ClientDeviceCreatedRow } from "../../infrastructure/rows";
import { CreatedClientDeviceDto, createdClientDeviceSchema } from "../dtos/created-client-device.dto";

export class CreatedClientDeviceMapper {
  static toResponse(r: ClientDeviceCreatedRow): CreatedClientDeviceDto {
    return createdClientDeviceSchema.parse({
      clientId: r.client_device_assignment_client_id,
      deviceId: r.client_device_assignment_device_id,
      location: r.client_device_assignment_device_location,
      assignedBy: r.client_device_assignment_assigned_by,
      assignedSince: r.client_device_assignment_assigned_since,
    });
  }
}
