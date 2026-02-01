-- migrate:up

ALTER TABLE auth.app_user ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.identity ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.app_user_root_membership ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization.organization ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization.app_user_organization_membership ENABLE ROW LEVEL SECURITY;
ALTER TABLE team.team ENABLE ROW LEVEL SECURITY;
ALTER TABLE team.app_user_team_membership ENABLE ROW LEVEL SECURITY;
ALTER TABLE client.client ENABLE ROW LEVEL SECURITY;
ALTER TABLE client.app_user_client_membership ENABLE ROW LEVEL SECURITY;
ALTER TABLE device.client_device_assignment ENABLE ROW LEVEL SECURITY;
ALTER TABLE device.device ENABLE ROW LEVEL SECURITY;
ALTER TABLE device.device_type ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION app.me()
RETURNS uuid LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT current_setting('app.current_user_id')::uuid
$$;

CREATE OR REPLACE FUNCTION app.get_admin_organizations()
RETURNS TABLE(organization_id uuid)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT organization_id
  FROM organization.app_user_organization_membership
  WHERE app_user_id = app.me() AND role = 'organization_admin'::role
$$;

CREATE OR REPLACE FUNCTION app.get_admin_teams()
RETURNS TABLE(team_id uuid)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT team_id
  FROM team.app_user_team_membership
  WHERE app_user_id = app.me() AND role = 'team_admin'::role
$$;

CREATE OR REPLACE FUNCTION app.get_member_or_admin_teams()
RETURNS TABLE(team_id uuid)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT team_id
  FROM team.app_user_team_membership
  WHERE app_user_id = app.me() AND (role = 'team_admin'::role OR role = 'team_member'::role)
$$;

CREATE OR REPLACE FUNCTION app.has_root_role(_role role)
RETURNS boolean LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM auth.app_user_root_membership m
    WHERE m.app_user_id = app.me() AND m.role = _role
  );
$$;

CREATE OR REPLACE FUNCTION app.has_org_role(_role role)
RETURNS boolean LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM organization.app_user_organization_membership m
    WHERE m.app_user_id = app.me() AND m.role = _role
  );
$$;

CREATE OR REPLACE FUNCTION app.has_team_role(_role role)
RETURNS boolean LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM team.app_user_team_membership m
    WHERE m.app_user_id = app.me() AND m.role = _role
  );
$$;

CREATE OR REPLACE FUNCTION app.has_client_role(_role role)
RETURNS boolean LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM client.app_user_client_membership m
    WHERE m.app_user_id = app.me() AND m.role = _role
  );
$$;

-- migrate:down

ALTER TABLE auth.app_user DISABLE ROW LEVEL SECURITY;
ALTER TABLE auth.identity DISABLE ROW LEVEL SECURITY;
ALTER TABLE auth.app_user_root_membership DISABLE ROW LEVEL SECURITY;
ALTER TABLE organization.organization DISABLE ROW LEVEL SECURITY;
ALTER TABLE organization.app_user_organization_membership DISABLE ROW LEVEL SECURITY;
ALTER TABLE team.team DISABLE ROW LEVEL SECURITY;
ALTER TABLE team.app_user_team_membership DISABLE ROW LEVEL SECURITY;
ALTER TABLE client.client DISABLE ROW LEVEL SECURITY;
ALTER TABLE client.app_user_client_membership DISABLE ROW LEVEL SECURITY;
ALTER TABLE device.device DISABLE ROW LEVEL SECURITY;
ALTER TABLE device.device_type DISABLE ROW LEVEL SECURITY;
ALTER TABLE device.client_device_assignment DISABLE ROW LEVEL SECURITY;

DROP FUNCTION IF EXISTS app.me();
DROP FUNCTION IF EXISTS app.get_admin_organizations();
DROP FUNCTION IF EXISTS app.get_admin_teams();
DROP FUNCTION IF EXISTS app.get_member_or_admin_teams();
DROP FUNCTION IF EXISTS app.has_root_role(role);
DROP FUNCTION IF EXISTS app.has_org_role(role);
DROP FUNCTION IF EXISTS app.has_team_role(role);
DROP FUNCTION IF EXISTS app.has_client_role(role);
