import { BaseUpdatable } from "@shared/ts/sql/fragments";

export type PatchClientInput = {
  gender?: "male" | "female" | "other";
  firstName?: string;
  lastName?: string;
  teamId?: string | null;
  archivedOn?: null;
  archivedBy?: null;
};

export class PatchClientUpdatable extends BaseUpdatable<PatchClientInput> {
  protected mapping = {
    gender: "gender",
    firstName: "first_name",
    lastName: "last_name",
    teamId: "team_id",
    archivedOn: "archived_on",
    archivedBy: "archived_by",
  } as const;
}
