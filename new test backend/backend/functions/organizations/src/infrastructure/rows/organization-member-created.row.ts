import { OrganizationRole } from "@shared/ts/entities";

export interface OrganizationMemberCreatedRow {
  app_user_organization_membership_organization_id: string;
  app_user_organization_membership_app_user_id: string;
  app_user_organization_membership_role: OrganizationRole;
  app_user_organization_membership_member_since: string;
  app_user_organization_membership_invited_by: string;
}
