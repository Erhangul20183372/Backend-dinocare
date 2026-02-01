import { BaseUpdatable } from "@shared/ts/sql/fragments";

export type UpdateTeamMemberInput = {
  userId: string;
  role?: string;
  memberSince?: string;
  memberUntil?: string | null;
};

export class UpdateTeamMemberUpdatable extends BaseUpdatable<UpdateTeamMemberInput> {
  protected mapping = {
    userId: "app_user_id",
    role: "role",
    memberSince: "member_since",
    memberUntil: "member_until",
  };
}
