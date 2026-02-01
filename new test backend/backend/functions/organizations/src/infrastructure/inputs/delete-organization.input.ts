import { currentUser, now } from "@shared/ts/db";
import { BaseUpdatable } from "@shared/ts/sql/fragments";

export class DeleteOrganizationUpdatable extends BaseUpdatable<{}> {
  protected mapping = {} as const;

  constructor(fields: Partial<{}>) {
    super(fields);
    this.addExpression("archived_on", now);
    this.addExpression("archived_by", currentUser);
  }
}
