export const OrganizationRole = {
  ORGANIZATION_ADMIN: "organization_admin",
  ORGANIZATION_MEMBER: "organization_member",
} as const;
export const TeamRole = {
  TEAM_ADMIN: "team_admin",
  TEAM_MEMBER: "team_member",
} as const;
export const ClientRole = {
  CLIENT_MEMBER: "client_member",
} as const;
export const AppRole = {
  APP_ADMIN: "app_admin",
  APP_MEMBER: "app_member",
} as const;

export type OrganizationRole = (typeof OrganizationRole)[keyof typeof OrganizationRole];
export type TeamRole = (typeof TeamRole)[keyof typeof TeamRole];
export type ClientRole = (typeof ClientRole)[keyof typeof ClientRole];
export type AppRole = (typeof AppRole)[keyof typeof AppRole];

export const organizationRoles = Object.values(OrganizationRole) as [OrganizationRole, ...OrganizationRole[]];
export const teamRoles = Object.values(TeamRole) as [TeamRole, ...TeamRole[]];
export const clientRoles = Object.values(ClientRole) as [ClientRole, ...ClientRole[]];
export const appRoles = Object.values(AppRole) as [AppRole, ...AppRole[]];
