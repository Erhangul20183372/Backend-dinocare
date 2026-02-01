-- migrate:up
ALTER TABLE organization.app_user_organization_membership
ADD CONSTRAINT one_active_org_membership_per_user
EXCLUDE USING gist (
  app_user_id WITH =,
  (archived_on IS NULL) WITH =
)
WHERE (archived_on IS NULL AND archived_by IS NULL);

ALTER TABLE auth.app_user_root_membership
ADD CONSTRAINT one_active_root_membership_per_user
EXCLUDE USING gist (
  app_user_id WITH =,
  (archived_on IS NULL) WITH =
)
WHERE (archived_on IS NULL AND archived_by IS NULL);

ALTER TABLE team.app_user_team_membership
ADD CONSTRAINT one_active_team_membership_per_user_per_team
EXCLUDE USING gist (
  app_user_id WITH =,
  team_id WITH =
)
WHERE (archived_on IS NULL AND archived_by IS NULL);

ALTER TABLE client.app_user_client_membership
ADD CONSTRAINT one_active_client_membership_per_user_per_client
EXCLUDE USING gist (
  app_user_id WITH =,
  client_id WITH =
)
WHERE (archived_on IS NULL AND archived_by IS NULL);

-- migrate:down
ALTER TABLE organization.app_user_organization_membership
DROP CONSTRAINT one_active_org_membership_per_user;

ALTER TABLE auth.app_user_root_membership
DROP CONSTRAINT one_active_root_membership_per_user;

ALTER TABLE team.app_user_team_membership
DROP CONSTRAINT one_active_team_membership_per_user_per_team;

ALTER TABLE client.app_user_client_membership
DROP CONSTRAINT one_active_client_membership_per_user_per_client;
