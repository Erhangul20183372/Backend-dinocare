import { OneUserRow } from "../../data/rows";
import { OneUserDto } from "../dtos/one-user.dto";

export class OneUserMapper {
  static toResponse(row: OneUserRow): OneUserDto {
    return {
      id: row.app_user_id,
      firstName: row.app_user_first_name,
      lastName: row.app_user_last_name,
    };
  }
}
