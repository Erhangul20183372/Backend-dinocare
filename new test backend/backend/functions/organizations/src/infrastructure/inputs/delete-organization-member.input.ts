import { currentUser, now } from "@shared/ts/db";
import { BaseUpdatable } from "@shared/ts/sql/fragments";

export class DeleteOrganizationMemberUpdatable extends BaseUpdatable<{}> {
  protected mapping = {} as const;

  constructor(fields: Partial<{}>) {
    super(fields);
    this.addExpression("archived_on", now);
    this.addExpression("archived_by", currentUser);
    this.addExpression("member_until", now);
  }
}
