import { OrganizationRole, TeamRole } from "@shared/ts/entities";

export interface AllUsersDto {
  id: string;
  firstName: string;
  lastName: string;
  organization: {
    id: string;
    role: OrganizationRole;
  };
  teams: {
    id: string;
    role: TeamRole;
  }[];
}
