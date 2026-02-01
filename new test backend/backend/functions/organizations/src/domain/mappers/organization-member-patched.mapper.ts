import { OrganizationMemberPatchedRow } from "../../infrastructure/rows";
import { OrganizationMemberPatchedDto, organizationMemberPatchedSchema } from "../dtos";

export class OrganizationMemberPatchedMapper {
  static toResponse(rows: OrganizationMemberPatchedRow): OrganizationMemberPatchedDto {
    return organizationMemberPatchedSchema.parse({
      id: rows.app_user_organization_membership_organization_id,
      appUserId: rows.app_user_organization_membership_app_user_id,
      role: rows.app_user_organization_membership_role,
    });
  }
}
