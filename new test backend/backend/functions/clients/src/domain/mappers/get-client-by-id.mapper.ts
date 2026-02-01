import { GetClientByIdRow } from "../../infrastructure/rows";
import { ClientsByIdDto, getClientByIdSchema } from "../dtos/get-client-by-id.dto";

export class GetClientByIdMapper {
  static toResponse(r: GetClientByIdRow): ClientsByIdDto {
    return getClientByIdSchema.parse({
      id: r.client_id,
      gender: r.client_gender,
      firstName: r.client_first_name,
      lastName: r.client_last_name,
      teamId: r.client_team_id,
    });
  }
}
