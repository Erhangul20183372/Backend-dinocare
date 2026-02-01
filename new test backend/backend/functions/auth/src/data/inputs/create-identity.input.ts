import { BaseInsertable } from "@shared/ts/sql/fragments";

export type CreateIdentityInput = {
  emailAddress: string;
  passwordHash: string;
};

export class CreateIdentityInsertable extends BaseInsertable<CreateIdentityInput> {
  protected mapping = {
    emailAddress: "email_address",
    passwordHash: "password_hash",
  } as const;
}
