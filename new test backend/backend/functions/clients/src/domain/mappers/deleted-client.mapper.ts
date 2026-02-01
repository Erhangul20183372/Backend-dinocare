import { ClientDeletedRow } from "../../infrastructure/rows";
import { DeletedClientDto, deletedClientSchema } from "../dtos/deleted-client.dto";

export class DeletedClientMapper {
  static toResponse(r: ClientDeletedRow): DeletedClientDto {
    return deletedClientSchema.parse({
      id: r.client_id,
      gender: r.client_gender,
      firstName: r.client_first_name,
      lastName: r.client_last_name,
      teamId: r.client_team_id,
      archivedOn: r.client_archived_on,
      archivedBy: r.client_archived_by,
    });
  }
}
