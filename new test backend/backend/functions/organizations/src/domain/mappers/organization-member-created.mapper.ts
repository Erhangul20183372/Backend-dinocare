import { OrganizationMemberCreatedRow } from "../../infrastructure/rows";
import { OrganizationMemberCreatedDto, organizationMemberCreatedSchema } from "../dtos";

export class OrganizationMemberCreatedMapper {
  static toResponse(rows: OrganizationMemberCreatedRow): OrganizationMemberCreatedDto {
    return organizationMemberCreatedSchema.parse({
      id: rows.app_user_organization_membership_organization_id,
      appUserId: rows.app_user_organization_membership_app_user_id,
      role: rows.app_user_organization_membership_role,
      invitedBy: rows.app_user_organization_membership_invited_by,
      memberSince: rows.app_user_organization_membership_member_since,
    });
  }
}
