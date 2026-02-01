export interface OrganizationDeletedRow {
  organization_id: string;
  organization_domain: string;
  organization_name: string;
  organization_logo_url: string | null;
  organization_archived_on: Date;
  organization_archived_by: string;
}
