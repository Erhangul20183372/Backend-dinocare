import { TeamRole } from "./enums";

export interface AppUserTeamMembershipEntity {
  team_id: string;
  app_user_id: string;
  member_since: Date;
  role: TeamRole;
  member_until: Date | null;
  invited_by: string;
  archived_on: Date | null;
  archived_by: string | null;
}
