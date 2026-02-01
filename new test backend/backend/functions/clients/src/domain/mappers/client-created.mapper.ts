import { ClientCreatedRow } from "../../infrastructure/rows";
import { ClientCreatedDto, clientCreatedSchema } from "../dtos/client-created.dto";

export class ClientCreatedMapper {
  static toResponse(r: ClientCreatedRow): ClientCreatedDto {
    return clientCreatedSchema.parse({
      id: r.client_id,
      teamId: r.client_team_id,
      gender: r.client_gender,
      firstName: r.client_first_name,
      lastName: r.client_last_name,
    });
  }
}
