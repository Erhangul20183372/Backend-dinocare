import { OrganizationMemberDeletedRow } from "../../infrastructure/rows";
import { OrganizationMemberDeletedDto, organizationMemberDeletedSchema } from "../dtos";

export class OrganizationMemberDeletedMapper {
  static toResponse(rows: OrganizationMemberDeletedRow): OrganizationMemberDeletedDto {
    return organizationMemberDeletedSchema.parse({
      id: rows.app_user_organization_membership_organization_id,
      appUserId: rows.app_user_organization_membership_app_user_id,
      role: rows.app_user_organization_membership_role,
      invitedBy: rows.app_user_organization_membership_invited_by,
      memberSince: rows.app_user_organization_membership_member_since,
      memberUntil: rows.app_user_organization_membership_member_until,
      archivedOn: rows.app_user_organization_membership_archived_on,
      archivedBy: rows.app_user_organization_membership_archived_by,
    });
  }
}
