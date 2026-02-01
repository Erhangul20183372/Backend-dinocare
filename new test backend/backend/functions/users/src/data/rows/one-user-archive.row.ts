import { OneUserRow } from "./one-user.row";

export interface OneUserArchiveRow extends OneUserRow {
  app_user_archived_on: Date;
  app_user_archived_by: string;
}
