import { BaseUpdatable } from "@shared/ts/sql/fragments";

export type PatchTeamInput = {
  name?: string;
  color?: string;
};

export class PatchTeamUpdatable extends BaseUpdatable<PatchTeamInput> {
  protected mapping = {
    name: "name",
    color: "color",
  } as const;
}
