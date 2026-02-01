import { OrganizationDeletedRow } from "../../infrastructure/rows";
import { OrganizationDeletedDto, organizationDeletedSchema } from "../dtos";

export class OrganizationDeletedMapper {
  static toResponse(rows: OrganizationDeletedRow): OrganizationDeletedDto {
    return organizationDeletedSchema.parse({
      id: rows.organization_id,
      domain: rows.organization_domain,
      name: rows.organization_name,
      logoUrl: rows.organization_logo_url,
      archivedOn: rows.organization_archived_on,
      archivedBy: rows.organization_archived_by,
    });
  }
}
