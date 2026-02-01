import { BaseFunctional } from "@shared/ts/sql/fragments";

export type LookupAppUserArgs = {
  identityId: string;
};

export class LookupAppUserFunction extends BaseFunctional<LookupAppUserArgs> {
  protected name = "app.lookup_app_user";
  protected returns = ["id"];
  protected returnType = "VALUE" as const;
}
