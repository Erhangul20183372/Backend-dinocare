import { AllOrganizationClientsRow } from "../../infrastructure/rows";
import { AllOrganizationClientsDto, allOrganizationClientsSchema } from "../dtos";

export class AllOrganizationClientsMapper {
  static toResponse(rows: AllOrganizationClientsRow[]): AllOrganizationClientsDto {
    return allOrganizationClientsSchema.parse({
      id: rows[0]?.organization_id,
      domain: rows[0]?.organization_domain,
      name: rows[0]?.organization_name,
      logoUrl: rows[0]?.organization_logo_url,
      clients: rows.map((r) => ({
        id: r.client_id,
        teamId: r.team_id,
        firstName: r.client_first_name,
        lastName: r.client_last_name,
        gender: r.client_gender,
      })),
    });
  }
}
