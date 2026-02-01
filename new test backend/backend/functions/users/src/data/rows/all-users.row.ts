import { OrganizationRole, TeamRole } from "@shared/ts/entities";

export interface AllUsersRow {
  app_user_id: string;
  app_user_first_name: string;
  app_user_last_name: string;
  app_user_team_membership_team_id: string;
  app_user_team_membership_role: TeamRole;
  app_user_organization_membership_organization_id: string;
  app_user_organization_membership_role: OrganizationRole;
}
