export interface AppUserEntity {
  id: string;
  identity_id: string;
  first_name: string;
  last_name: string;
  archived_on: Date | null;
  archived_by: string | null;
}
