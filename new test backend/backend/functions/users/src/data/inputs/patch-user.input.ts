import { BaseUpdatable } from "@shared/ts/sql/fragments";

export type PatchUserInput = {
  firstName?: string;
  lastName?: string;
};

export class PatchUserUpdatable extends BaseUpdatable<PatchUserInput> {
  protected mapping = {
    firstName: "first_name",
    lastName: "last_name",
  } as const;
}
