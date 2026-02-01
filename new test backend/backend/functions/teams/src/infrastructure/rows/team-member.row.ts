import { TeamRole } from "@shared/ts/entities";

export interface TeamMemberRow {
  app_user_team_membership_app_user_id: string;
  app_user_team_membership_role: TeamRole;
  app_user_team_membership_member_since: string;
  app_user_team_membership_member_until: string | null;
  app_user_team_membership_invited_by: string;
  app_user_first_name: string;
  app_user_last_name: string;
}
