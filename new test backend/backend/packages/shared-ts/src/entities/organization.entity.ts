export interface OrganizationEntity {
  id: string;
  domain: string;
  name: string;
  logo_url: string | null;
  archived_on: Date | null;
  archived_by: string | null;
}
