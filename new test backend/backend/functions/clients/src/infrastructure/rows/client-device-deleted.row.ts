export interface ClientDeviceDeletedRow {
  client_device_assignment_client_id: string;
  client_device_assignment_device_id: string;
  client_device_assignment_assigned_since: Date;
  client_device_assignment_assigned_until: Date;
  client_device_assignment_assigned_by: string;
  client_device_assignment_unassigned_by: string;
  client_device_assignment_device_location: string | null;
}
