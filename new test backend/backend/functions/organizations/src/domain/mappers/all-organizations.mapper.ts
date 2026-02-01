import { AllOrganizationsRow } from "../../infrastructure/rows";
import { AllOrganizationsDto, allOrganizationsSchema } from "../dtos";

export class AllOrganizationsMapper {
  static toResponse(rows: AllOrganizationsRow): AllOrganizationsDto {
    return allOrganizationsSchema.parse({
      id: rows.organization_id,
      domain: rows.organization_domain,
      name: rows.organization_name,
      logoUrl: rows.organization_logo_url,
    });
  }
}
