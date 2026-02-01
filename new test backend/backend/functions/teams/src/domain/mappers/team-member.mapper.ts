import { TeamMemberRow } from "../../infrastructure/rows/team-member.row";
import { TeamMemberModel } from "../models/team-member.model";

export class TeamMemberMapper {
  static toModel(row: TeamMemberRow): TeamMemberModel {
    return {
      userId: row.app_user_team_membership_app_user_id,
      firstName: row.app_user_first_name,
      lastName: row.app_user_last_name,
      role: row.app_user_team_membership_role,
      memberSince: new Date(row.app_user_team_membership_member_since),
      memberUntil: row.app_user_team_membership_member_until
        ? new Date(row.app_user_team_membership_member_until)
        : null,
      invitedBy: row.app_user_team_membership_invited_by,
    };
  }
}
