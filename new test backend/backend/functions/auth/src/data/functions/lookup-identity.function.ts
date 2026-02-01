import { BaseFunctional } from "@shared/ts/sql/fragments";

export type LookupIdentityArgs = {
  email: string;
};

export class LookupIdentityFunction extends BaseFunctional<LookupIdentityArgs> {
  protected name = "app.lookup_identity";
  protected returns = ["id", "email_address", "password_hash"];
  protected returnType = "TABLE" as const;

  constructor(input: LookupIdentityArgs) {
    super({
      ...input,
      email: input.email.toLowerCase(),
    });
  }
}
