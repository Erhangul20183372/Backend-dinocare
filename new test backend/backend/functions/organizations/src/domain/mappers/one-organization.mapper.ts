import { GetOrganizationByIdRow } from "../../infrastructure/rows";
import { OneOrganizationDto, oneOrganizationSchema } from "../dtos";

export class OneOrganizationMapper {
  static toResponse(rows: GetOrganizationByIdRow): OneOrganizationDto {
    return oneOrganizationSchema.parse({
      id: rows.organization_id,
      domain: rows.organization_domain,
      name: rows.organization_name,
      logoUrl: rows.organization_logo_url,
    });
  }
}
