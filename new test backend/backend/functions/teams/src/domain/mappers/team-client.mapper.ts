import { TeamClientRow } from "../../infrastructure/rows/team-client.row";
import { TeamClientModel } from "../models/team-client.model";

export class TeamClientMapper {
  static toModel(r: TeamClientRow): TeamClientModel {
    return {
      clientId: r.client_id,
      teamId: r.client_team_id,
      firstName: r.client_first_name,
      lastName: r.client_last_name,
      gender: r.client_gender,
    };
  }
}
