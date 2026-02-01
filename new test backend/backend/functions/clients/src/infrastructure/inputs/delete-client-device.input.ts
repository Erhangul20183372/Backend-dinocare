import { currentUser, now } from "@shared/ts/db";
import { BaseUpdatable } from "@shared/ts/sql/fragments";

export class DeleteClientDeviceUpdatable extends BaseUpdatable<{}> {
  protected mapping = {} as const;

  constructor(fields: Partial<{}>) {
    super(fields);
    this.addExpression("assigned_until", now);
    this.addExpression("unassigned_by", currentUser);
  }
}
