import { TeamRole } from "@shared/ts/entities";
import { BaseInsertable } from "@shared/ts/sql/fragments";

export type AddTeamMemberInput = {
  teamId: string;
  userId: string;
  role: TeamRole;
  memberUntil?: string;
};

export class AddTeamMemberInsertable extends BaseInsertable<AddTeamMemberInput> {
  protected mapping = {
    teamId: "team_id",
    userId: "app_user_id",
    role: "role",
    memberUntil: "member_until",
  } as const;

  constructor(input: AddTeamMemberInput) {
    super(input);
    this.addExpression("member_since", "NOW()");
    this.addExpression("invited_by", "current_setting('app.current_user_id', true)::uuid");
  }
}
