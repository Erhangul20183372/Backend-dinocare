export interface ClientPatchedRow {
  client_id: string;
  client_gender: "male" | "female" | "other";
  client_first_name: string;
  client_last_name: string;
  client_team_id: string;
  client_archived_on: Date | null;
  client_archived_by: string | null;
}
