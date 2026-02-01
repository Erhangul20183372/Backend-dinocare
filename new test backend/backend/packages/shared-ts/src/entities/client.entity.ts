export interface ClientEntity {
  id: string;
  team_id: string;
  gender: "male" | "female" | "other";
  first_name: string;
  last_name: string;
  archived_on: Date | null;
  archived_by: string | null;
}
