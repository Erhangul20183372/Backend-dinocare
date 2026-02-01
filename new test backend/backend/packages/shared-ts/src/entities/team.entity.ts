export interface TeamEntity {
  id: string;
  organization_id: string;
  name: string;
  color: string;
  archived_on: Date | null;
  archived_by: string | null;
}
