import { OrganizationRole } from "@shared/ts/entities";

export interface AllOrganizationMembersRow {
  organization_id: string;
  organization_domain: string;
  organization_name: string;
  organization_logo_url: string | null;
  app_user_organization_membership_app_user_id: string;
  app_user_organization_membership_role: OrganizationRole;
}
