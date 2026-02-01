import { BaseInsertable } from "@shared/ts/sql/fragments";

export type CreateOrganizationInput = {
  domain: string;
  name: string;
  logoUrl?: string;
};

export class CreateOrganizationInsertable extends BaseInsertable<CreateOrganizationInput> {
  protected mapping = {
    domain: "domain",
    name: "name",
    logoUrl: "logo_url",
  } as const;
}
