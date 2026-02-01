import { AllOrganizationTeamsRow } from "../../infrastructure/rows";
import { AllOrganizationTeamsDto, allOrganizationTeamsSchema } from "../dtos";

export class AllOrganizationTeamsMapper {
  static toResponse(rows: AllOrganizationTeamsRow[]): AllOrganizationTeamsDto {
    return allOrganizationTeamsSchema.parse({
      id: rows[0]?.organization_id,
      domain: rows[0]?.organization_domain,
      name: rows[0]?.organization_name,
      logoUrl: rows[0]?.organization_logo_url,
      teams: rows.map((r) => ({
        id: r.team_id,
        name: r.team_name,
        color: r.team_color,
      })),
    });
  }
}
