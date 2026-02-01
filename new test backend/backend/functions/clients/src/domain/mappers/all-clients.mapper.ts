import { AllClientsRow } from "../../infrastructure/rows";
import { ClientWithTeamDto, clientWithTeamSchema } from "../dtos/all-clients.dto";

export class AllClientsMapper {
  static toResponse(r: AllClientsRow): ClientWithTeamDto {
    return clientWithTeamSchema.parse({
      id: r.client_id,
      gender: r.client_gender,
      firstName: r.client_first_name,
      lastName: r.client_last_name,
      teamId: r.team_id,
      teamName: r.team_name,
    });
  }
}
