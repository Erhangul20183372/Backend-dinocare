import type { TeamRow } from "../../infrastructure/rows/team.row";
import { TeamModel } from "../models/team.model";

export class TeamMapper {
  static toModel(row: TeamRow): TeamModel {
    return {
      id: row.team_id,
      organizationId: row.team_organization_id,
      name: row.team_name,
      color: row.team_color,
    };
  }
}
