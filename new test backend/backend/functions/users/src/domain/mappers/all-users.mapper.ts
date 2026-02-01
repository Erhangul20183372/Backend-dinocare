import { AllUsersRow } from "../../data/rows";
import { AllUsersDto } from "../dtos";

export class AllUsersMapper {
  static toResponse(rows: AllUsersRow[]): AllUsersDto[] {
    const map = new Map<string, AllUsersDto>();

    for (const r of rows) {
      let user = map.get(r.app_user_id);
      if (!user) {
        user = {
          id: r.app_user_id,
          firstName: r.app_user_first_name,
          lastName: r.app_user_last_name,
          organization: {
            id: r.app_user_organization_membership_organization_id,
            role: r.app_user_organization_membership_role,
          },
          teams: [],
        };
        map.set(r.app_user_id, user);
      }

      if (r.app_user_team_membership_team_id && r.app_user_team_membership_role) {
        user.teams.push({
          id: r.app_user_team_membership_team_id,
          role: r.app_user_team_membership_role,
        });
      }
    }

    return Array.from(map.values());
  }
}
