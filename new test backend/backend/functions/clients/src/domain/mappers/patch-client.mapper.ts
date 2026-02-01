import { ClientPatchedRow } from "../../infrastructure/rows";
import { PatchedClientDto, patchedClientSchema } from "../dtos/patched-client.dto";

export class PatchClientMapper {
  static toResponse(r: ClientPatchedRow): PatchedClientDto {
    return patchedClientSchema.parse({
      id: r.client_id,
      gender: r.client_gender,
      firstName: r.client_first_name,
      lastName: r.client_last_name,
      teamId: r.client_team_id,
      archived_on: r.client_archived_on,
      archived_by: r.client_archived_by,
    });
  }
}
