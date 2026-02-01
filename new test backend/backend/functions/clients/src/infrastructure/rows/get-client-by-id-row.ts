export interface GetClientByIdRow {
  client_id: string;
  client_gender: "male" | "female" | "other";
  client_first_name: string;
  client_last_name: string;
  client_team_id: string;
}
