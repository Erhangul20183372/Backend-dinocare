import { ClientDevicePatchedRow } from "../../infrastructure/rows";
import { ClientDevicePatchedDto, clientDevicePatchedSchema } from "../dtos/client-device-patched.dto";

export class ClientDevicePatchedMapper {
  static toResponse(r: ClientDevicePatchedRow): ClientDevicePatchedDto {
    return clientDevicePatchedSchema.parse({
      clientId: r.client_device_assignment_client_id,
      deviceId: r.client_device_assignment_device_id,
      location: r.client_device_assignment_device_location,
    });
  }
}
