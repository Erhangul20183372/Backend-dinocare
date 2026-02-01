-- migrate:up

ALTER TABLE auth.app_user
    ADD COLUMN archived_on TIMESTAMPTZ NULL,
    ADD COLUMN archived_by UUID NULL REFERENCES auth.app_user(id);

ALTER TABLE organization.app_user_organization_membership
    ADD COLUMN archived_on TIMESTAMPTZ NULL,
    ADD COLUMN archived_by UUID NULL REFERENCES auth.app_user(id);

ALTER TABLE team.app_user_team_membership
    ADD COLUMN archived_on TIMESTAMPTZ NULL,
    ADD COLUMN archived_by UUID NULL REFERENCES auth.app_user(id);

ALTER TABLE client.app_user_client_membership
    ADD COLUMN archived_on TIMESTAMPTZ NULL,
    ADD COLUMN archived_by UUID NULL REFERENCES auth.app_user(id);

ALTER TABLE organization.organization
    ADD COLUMN archived_on TIMESTAMPTZ NULL,
    ADD COLUMN archived_by UUID NULL REFERENCES auth.app_user(id);

ALTER TABLE team.team
    DROP COLUMN is_archived,
    ADD COLUMN archived_on TIMESTAMPTZ NULL,
    ADD COLUMN archived_by UUID NULL REFERENCES auth.app_user(id);

ALTER TABLE client.client
    DROP COLUMN is_archived,
    ADD COLUMN archived_on TIMESTAMPTZ NULL,
    ADD COLUMN archived_by UUID NULL REFERENCES auth.app_user(id);

ALTER TABLE auth.app_user_root_membership
    ADD COLUMN archived_on TIMESTAMPTZ NULL,
    ADD COLUMN archived_by UUID NULL REFERENCES auth.app_user(id);

-- migrate:down

ALTER TABLE auth.app_user
    DROP COLUMN archived_on,
    DROP COLUMN archived_by;

ALTER TABLE organization.app_user_organization_membership
    DROP COLUMN archived_on,
    DROP COLUMN archived_by;

ALTER TABLE team.app_user_team_membership
    DROP COLUMN archived_on,
    DROP COLUMN archived_by;

ALTER TABLE client.app_user_client_membership
    DROP COLUMN archived_on,
    DROP COLUMN archived_by;

ALTER TABLE organization.organization
    DROP COLUMN archived_on,
    DROP COLUMN archived_by;

ALTER TABLE team.team
    DROP COLUMN archived_on,
    DROP COLUMN archived_by,
    ADD COLUMN is_archived BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE client.client
    DROP COLUMN archived_on,
    DROP COLUMN archived_by,
    ADD COLUMN is_archived BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE auth.app_user_root_membership
    DROP COLUMN archived_on,
    DROP COLUMN archived_by;