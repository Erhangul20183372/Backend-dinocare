import { currentUser, now } from "@shared/ts/db";
import { OrganizationRole } from "@shared/ts/entities";
import { BaseInsertable } from "@shared/ts/sql/fragments";

export type CreateOrganizationMemberInput = {
  id: string;
  appUserId: string;
  role: OrganizationRole;
};

export class CreateOrganizationMemberInsertable extends BaseInsertable<CreateOrganizationMemberInput> {
  protected mapping = {
    id: "organization_id",
    appUserId: "app_user_id",
    role: "role",
  } as const;

  constructor(input: CreateOrganizationMemberInput) {
    super(input);
    this.addExpression("invited_by", currentUser);
    this.addExpression("member_since", now);
  }
}
