import { AllOrganizationMembersRow } from "../../infrastructure/rows";
import { AllOrganizationMembersDto, allOrganizationMembersSchema } from "../dtos";

export class AllOrganizationMembersMapper {
  static toResponse(rows: AllOrganizationMembersRow[]): AllOrganizationMembersDto {
    return allOrganizationMembersSchema.parse({
      id: rows[0]?.organization_id,
      domain: rows[0]?.organization_domain,
      name: rows[0]?.organization_name,
      logoUrl: rows[0]?.organization_logo_url,
      members: rows.map((r) => ({
        id: r.app_user_organization_membership_app_user_id,
        role: r.app_user_organization_membership_role,
      })),
    });
  }
}
