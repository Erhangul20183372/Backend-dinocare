-- migrate:up
ALTER TABLE organization.organization
ALTER COLUMN domain TYPE CITEXT;

ALTER TABLE organization.organization
DROP CONSTRAINT IF EXISTS domain_format_chk,
ADD CONSTRAINT domain_format_chk
CHECK (domain ~ '^(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$');

ALTER TABLE auth.identity
ALTER COLUMN email_address TYPE CITEXT;

ALTER TABLE auth.identity
ADD CONSTRAINT email_format_chk
CHECK (email_address ~* '^[^@\s]+@[^@\s]+.[^@\s]+$');

ALTER TABLE device.client_device_assignment
ALTER COLUMN assigned_since SET DEFAULT now();

ALTER TABLE auth.app_user_root_membership
ALTER COLUMN member_since SET DEFAULT now();

ALTER TABLE organization.app_user_organization_membership
ALTER COLUMN member_since SET DEFAULT now();

ALTER TABLE team.app_user_team_membership
ALTER COLUMN member_since SET DEFAULT now();

ALTER TABLE client.app_user_client_membership
ALTER COLUMN member_since SET DEFAULT now();

-- migrate:down

ALTER TABLE organization.organization
ALTER COLUMN domain TYPE TEXT;

ALTER TABLE organization.organization
DROP CONSTRAINT IF EXISTS domain_format_chk,
ADD CONSTRAINT domain_format_chk
CHECK (domain ~ '^[A-Za-z0-9.-]+.[A-Za-z]{2,}$');

ALTER TABLE auth.identity
ALTER COLUMN email_address TYPE TEXT;

ALTER TABLE auth.identity
DROP CONSTRAINT IF EXISTS email_format_chk;

ALTER TABLE device.client_device_assignment
ALTER COLUMN assigned_since SET DEFAULT now();

ALTER TABLE auth.app_user_root_membership
ALTER COLUMN member_since SET DEFAULT now();

ALTER TABLE organization.app_user_organization_membership
ALTER COLUMN member_since SET DEFAULT now();

ALTER TABLE team.app_user_team_membership
ALTER COLUMN member_since SET DEFAULT now();

ALTER TABLE client.app_user_client_membership
ALTER COLUMN member_since SET DEFAULT now();