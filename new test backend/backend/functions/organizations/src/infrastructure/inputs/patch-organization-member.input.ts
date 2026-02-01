import { OrganizationRole } from "@shared/ts/entities";
import { BaseUpdatable } from "@shared/ts/sql/fragments";

export type PatchOrganizationMemberInput = {
  role: OrganizationRole;
};

export class PatchOrganizationMemberUpdatable extends BaseUpdatable<PatchOrganizationMemberInput> {
  protected mapping = {
    role: "role",
  } as const;
}
