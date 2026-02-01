import { OrganizationPatchedRow } from "../../infrastructure/rows";
import { OrganizationPatchedDto, organizationPatchedSchema } from "../dtos";

export class OrganizationPatchedMapper {
  static toResponse(rows: OrganizationPatchedRow): OrganizationPatchedDto {
    return organizationPatchedSchema.parse({
      id: rows.organization_id,
      domain: rows.organization_domain,
      name: rows.organization_name,
      logoUrl: rows.organization_logo_url,
    });
  }
}
