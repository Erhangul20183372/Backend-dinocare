import { BaseUpdatable } from "@shared/ts/sql/fragments";

export type PatchOrganizationInput = {
  domain?: string;
  name?: string;
  logoUrl?: string | null;
};

export class PatchOrganizationUpdatable extends BaseUpdatable<PatchOrganizationInput> {
  protected mapping = {
    domain: "domain",
    name: "name",
    logoUrl: "logo_url",
  } as const;
}
