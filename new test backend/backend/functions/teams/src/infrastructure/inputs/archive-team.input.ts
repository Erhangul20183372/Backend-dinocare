import { BaseUpdatable } from "@shared/ts/sql/fragments";

export class ArchiveTeamInput extends BaseUpdatable<{}> {
  protected mapping = {} as const;

  constructor(fields: Partial<{}>) {
    super(fields);
    this.addExpression("archived_on", "NOW()");
    this.addExpression("archived_by", "current_setting('app.current_user_id', true)::uuid");
  }
}
