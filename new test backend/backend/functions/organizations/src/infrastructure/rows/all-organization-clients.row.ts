import { Gender } from "@shared/ts/entities";

export interface AllOrganizationClientsRow {
  organization_id: string;
  organization_domain: string;
  organization_name: string;
  organization_logo_url: string | null;
  team_id: string;
  client_id: string;
  client_first_name: string;
  client_last_name: string;
  client_gender: Gender;
}
