import { AddTeamMemberRow } from "../../infrastructure/rows/add-team-member.row";
import { TeamMemberModel } from "../models/team-member.model";

export class AddTeamMemberMapper {
  static toModel(r: AddTeamMemberRow): TeamMemberModel {
    return {
      userId: r.app_user_team_membership_app_user_id,
      role: r.app_user_team_membership_role,
      firstName: r.app_user_first_name,
      lastName: r.app_user_last_name,
      memberSince: new Date(r.app_user_team_membership_member_since),
      memberUntil: r.app_user_team_membership_member_until ? new Date(r.app_user_team_membership_member_until) : null,
      invitedBy: r.app_user_team_membership_invited_by,
    };
  }
}
