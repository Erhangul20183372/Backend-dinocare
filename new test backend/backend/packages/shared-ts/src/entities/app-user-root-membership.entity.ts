import { AppRole } from "./enums";

export interface AppUserRootMembershipEntity {
  app_user_id: string;
  member_since: Date;
  member_until: Date | null;
  role: AppRole;
  invited_by: string;
  archived_on: Date | null;
  archived_by: string | null;
}
