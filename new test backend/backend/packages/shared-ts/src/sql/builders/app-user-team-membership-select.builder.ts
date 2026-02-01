import { AppUserTeamMembershipEntity } from "../../entities";
import { BaseSelectBuilder } from "./base-select.builder";

export class AppUserTeamMembershipSelectBuilder extends BaseSelectBuilder {
  private static schema = "team";
  private static table = "app_user_team_membership";

  static override name = `${this.schema}.${this.table}`;
  static override columns: Record<keyof AppUserTeamMembershipEntity, string> = {
    team_id: `$table.team_id AS ${this.table}_team_id`,
    app_user_id: `$table.app_user_id AS ${this.table}_app_user_id`,
    member_since: `$table.member_since AS ${this.table}_member_since`,
    role: `$table.role AS ${this.table}_role`,
    member_until: `$table.member_until AS ${this.table}_member_until`,
    invited_by: `$table.invited_by AS ${this.table}_invited_by`,
    archived_on: `$table.archived_on AS ${this.table}_archived_on`,
    archived_by: `$table.archived_by AS ${this.table}_archived_by`,
  } as const;
}
