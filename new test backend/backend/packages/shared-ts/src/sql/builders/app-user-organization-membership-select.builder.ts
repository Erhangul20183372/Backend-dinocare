import { AppUserOrganizationMembershipEntity } from "../../entities/app-user-organization-membership.entity";
import { BaseSelectBuilder } from "./base-select.builder";

export class AppUserOrganizationMembershipSelectBuilder extends BaseSelectBuilder {
  private static schema = "organization";
  private static table = "app_user_organization_membership";

  static override name = `${this.schema}.${this.table}`;
  static override columns: Record<keyof AppUserOrganizationMembershipEntity, string> = {
    organization_id: `$table.organization_id AS ${this.table}_organization_id`,
    app_user_id: `$table.app_user_id AS ${this.table}_app_user_id`,
    member_since: `$table.member_since AS ${this.table}_member_since`,
    role: `$table.role AS ${this.table}_role`,
    member_until: `$table.member_until AS ${this.table}_member_until`,
    invited_by: `$table.invited_by AS ${this.table}_invited_by`,
    archived_on: `$table.archived_on AS ${this.table}_archived_on`,
    archived_by: `$table.archived_by AS ${this.table}_archived_by`,
  } as const;
}
