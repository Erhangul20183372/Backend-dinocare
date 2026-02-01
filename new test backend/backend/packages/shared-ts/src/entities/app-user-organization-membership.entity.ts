import { OrganizationRole } from "./enums";

export interface AppUserOrganizationMembershipEntity {
  organization_id: string;
  app_user_id: string;
  member_since: Date;
  role: OrganizationRole;
  member_until: Date | null;
  invited_by: string;
  archived_on: Date | null;
  archived_by: string | null;
}
