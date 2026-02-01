import { OrganizationRole } from "@shared/ts/entities";

export interface OrganizationMemberPatchedRow {
  app_user_organization_membership_organization_id: string;
  app_user_organization_membership_app_user_id: string;
  app_user_organization_membership_role: OrganizationRole;
}
