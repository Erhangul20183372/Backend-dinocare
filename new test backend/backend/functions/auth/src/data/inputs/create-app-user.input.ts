import { BaseInsertable } from "@shared/ts/sql/fragments";

export type CreateAppUserInput = {
  identityId: string;
  firstName: string;
  lastName: string;
};

export class CreateAppUserInsertable extends BaseInsertable<CreateAppUserInput> {
  protected mapping = {
    identityId: "identity_id",
    firstName: "first_name",
    lastName: "last_name",
  } as const;
}
