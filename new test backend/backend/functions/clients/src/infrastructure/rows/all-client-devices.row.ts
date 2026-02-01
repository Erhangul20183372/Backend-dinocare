export interface AllClientDevicesRow {
  client_id: string;
  client_team_id: string;
  client_first_name: string;
  client_last_name: string;
  client_gender: "male" | "female" | "other";
  device_id: string;
  device_sticker_id: string;
  device_serial_number: string;
  device_status: "active" | "inactive" | "retired" | "in_repair";
  device_type_name: string;
  client_device_assignment_assigned_since: Date;
  client_device_assignment_assigned_until: Date | null;
  client_device_assignment_assigned_by: string;
  client_device_assignment_unassigned_by: string | null;
  client_device_assignment_device_location: string | null;
}
