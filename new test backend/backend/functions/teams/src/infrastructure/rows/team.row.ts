export interface TeamRow {
  team_id: string;
  team_organization_id: string;
  team_name: string;
  team_color: string;
  team_archived_on: Date | null;
  team_archived_by: string | null;
}
