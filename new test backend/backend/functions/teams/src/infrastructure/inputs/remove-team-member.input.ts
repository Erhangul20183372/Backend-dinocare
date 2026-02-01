import { BaseUpdatable } from "@shared/ts/sql/fragments";

export class RemoveTeamMemberUpdatable extends BaseUpdatable<{}> {
  protected mapping = {} as const;

  constructor(input: Partial<{}>) {
    super(input);

    this.addExpression("member_until", "NOW()");
    this.addExpression("archived_on", "NOW()");
    this.addExpression("archived_by", "current_setting('app.current_user_id', true)::uuid");
  }
}
