import { BaseInsertable } from "@shared/ts/sql/fragments";

export type CreateTeamInput = {
  name: string;
  organizationId: string;
  color?: string;
};

export class CreateTeamInsertable extends BaseInsertable<CreateTeamInput> {
  protected mapping = {
    name: "name",
    organizationId: "organization_id",
    color: "color",
  } as const;
}
