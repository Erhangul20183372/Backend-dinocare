export interface ClientDeviceAssignmentEntity {
  client_id: string;
  device_id: string;
  assigned_since: Date;
  assigned_until: Date | null;
  assigned_by: string;
  unassigned_by: string | null;
  device_location: string;
}
