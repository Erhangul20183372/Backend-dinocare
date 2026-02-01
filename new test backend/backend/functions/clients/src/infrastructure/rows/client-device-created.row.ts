export interface ClientDeviceCreatedRow {
  client_device_assignment_client_id: string;
  client_device_assignment_device_id: string;
  client_device_assignment_device_location: string | null;
  client_device_assignment_assigned_by: string;
  client_device_assignment_assigned_since: Date;
}
