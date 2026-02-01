import { currentUser } from "@shared/ts/db";
import { OrganizationRole } from "@shared/ts/entities";
import { BaseInsertable } from "@shared/ts/sql/fragments";

export type CreateOrganizationMembershipInput = {
  organizationId: string;
  appUserId: string;
  role: OrganizationRole;
};

export class CreateOrganizationMembershipInsertable extends BaseInsertable<CreateOrganizationMembershipInput> {
  protected mapping = {
    organizationId: "organization_id",
    appUserId: "app_user_id",
    role: "role",
  };

  constructor(input: CreateOrganizationMembershipInput) {
    super(input);
    this.addExpression("invited_by", currentUser);
  }
}
