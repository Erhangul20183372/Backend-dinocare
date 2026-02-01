import { OneUserArchiveRow } from "../../data/rows";
import { OneUserArchiveDto } from "../dtos";

export class OneUserArchiveMapper {
  static toResponse(row: OneUserArchiveRow): OneUserArchiveDto {
    return {
      id: row.app_user_id,
      firstName: row.app_user_first_name,
      lastName: row.app_user_last_name,
      archivedOn: row.app_user_archived_on,
      archivedBy: row.app_user_archived_by,
    };
  }
}
