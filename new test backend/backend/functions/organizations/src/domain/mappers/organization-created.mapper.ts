import { OrganizationCreatedRow } from "../../infrastructure/rows";
import { OrganizationCreatedDto, organizationCreatedSchema } from "../dtos";

export class OrganizationCreatedMapper {
  static toResponse(rows: OrganizationCreatedRow): OrganizationCreatedDto {
    return organizationCreatedSchema.parse({
      id: rows.organization_id,
      domain: rows.organization_domain,
      name: rows.organization_name,
      logoUrl: rows.organization_logo_url,
    });
  }
}
