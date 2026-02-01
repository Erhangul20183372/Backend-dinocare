-- migrate:up
CREATE OR REPLACE FUNCTION app.identity__scope__self(_target_identity uuid, _operation text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT _target_identity = u.identity_id
  FROM auth.app_user u
  WHERE u.id = app.me();
$$;

CREATE OR REPLACE FUNCTION app.app_user__scope__self(_target_user uuid, _operation text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT _target_user = app.me();
$$;

CREATE OR REPLACE FUNCTION app.app_user__scope__organization(_target_user uuid, _operation text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM organization.app_user_organization_membership m
    WHERE m.app_user_id = _target_user
      AND m.organization_id IN (
        SELECT organization_id FROM app.get_admin_organizations()
      )
  );
$$;

CREATE OR REPLACE FUNCTION app.app_user__scope__team(_target_user uuid, _operation text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM team.app_user_team_membership m
    WHERE m.app_user_id = _target_user
      AND m.team_id IN (
        SELECT team_id FROM app.get_admin_teams()
      )
  );
$$;

CREATE OR REPLACE FUNCTION app.app_user_organization_membership__scope__self(
  _target_app_user uuid,
  _target_organization uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT _target_app_user = app.me();
$$;

CREATE OR REPLACE FUNCTION app.app_user_organization_membership__scope__organization(
  _target_app_user uuid,
  _target_organization uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT
    _target_organization IN (
      SELECT organization_id FROM app.get_admin_organizations()
    )
    AND (
      _operation <> 'update'
      OR _target_app_user <> app.me()
    );
$$;

CREATE OR REPLACE FUNCTION app.organization__scope__self(
  _target_organization uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM organization.app_user_organization_membership m
    WHERE m.organization_id = _target_organization
      AND m.app_user_id = app.me()
  );
$$;

CREATE OR REPLACE FUNCTION app.app_user_team_membership__scope__self(
  _target_app_user uuid,
  _target_team uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT _target_app_user = app.me();
$$;

CREATE OR REPLACE FUNCTION app.app_user_team_membership__scope__organization(
  _target_app_user uuid,
  _target_team uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT
    t.organization_id IN (
      SELECT organization_id FROM app.get_admin_organizations()
    )
    AND (
      _operation = 'read'
      OR (
        _target_app_user <> app.me()
        AND EXISTS (
          SELECT 1
          FROM organization.app_user_organization_membership m
          WHERE m.app_user_id = _target_app_user
            AND m.organization_id = t.organization_id
        )
      )
    )
  FROM team.team t
  WHERE t.id = _target_team;
$$;

CREATE OR REPLACE FUNCTION app.app_user_team_membership__scope__team(
  _target_app_user uuid,
  _target_team uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT
    _target_team IN (
      SELECT team_id FROM app.get_admin_teams()
    )
    AND (
      _operation = 'read'
      OR (
        _target_app_user <> app.me()
        AND EXISTS (
          SELECT 1
          FROM team.app_user_team_membership m
          WHERE m.app_user_id = _target_app_user
            AND m.team_id = _target_team
        )
      )
    );
$$;

CREATE OR REPLACE FUNCTION app.team__scope__self(
  _target_team uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM team.app_user_team_membership m
    WHERE m.team_id = _target_team
      AND m.app_user_id = app.me()
      AND (
        _operation = 'read'
        OR m.role = 'team_admin'::role
      )
  );
$$;


CREATE OR REPLACE FUNCTION app.team__scope__organization(
  _target_organization uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT _target_organization IN (
    SELECT organization_id FROM app.get_admin_organizations()
  );
$$;


CREATE OR REPLACE FUNCTION app.app_user_client_membership__scope__self(
  _target_app_user uuid,
  _target_client uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT _target_app_user = app.me();
$$;

CREATE OR REPLACE FUNCTION app.client__scope__self(
  _target_client uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM client.app_user_client_membership m
    WHERE m.client_id = _target_client
      AND m.app_user_id = app.me()
  );
$$;


CREATE OR REPLACE FUNCTION app.client__scope__organization(
  _target_team uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT _target_team IN (
    SELECT t.id
    FROM team.team t
    WHERE t.organization_id IN (
      SELECT organization_id FROM app.get_admin_organizations()
    )
  );
$$;

CREATE OR REPLACE FUNCTION app.client__scope__team(
  _target_team uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT _target_team IN (
    SELECT team_id FROM app.get_member_or_admin_teams()
  );
$$;

CREATE OR REPLACE FUNCTION app.client_device_assignment__scope__self(
  _target_client uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM client.app_user_client_membership m
    WHERE m.client_id = _target_client
      AND m.app_user_id = app.me()
  );
$$;

CREATE OR REPLACE FUNCTION app.client_device_assignment__scope__organization(
  _target_client uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT c.team_id IN (
    SELECT t.id
    FROM team.team t
    WHERE t.organization_id IN (
      SELECT organization_id FROM app.get_admin_organizations()
    )
  )
  FROM client.client c
  WHERE c.id = _target_client;
$$;

CREATE OR REPLACE FUNCTION app.client_device_assignment__scope__team(
  _target_client uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT c.team_id IN (
    SELECT team_id FROM app.get_member_or_admin_teams()
  )
  FROM client.client c
  WHERE c.id = _target_client;
$$;

CREATE OR REPLACE FUNCTION app.device__scope__self(
  _target_device uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM device.client_device_assignment a
    JOIN client.app_user_client_membership m
      ON m.client_id = a.client_id
    WHERE a.device_id = _target_device
      AND m.app_user_id = app.me()
  );
$$;

CREATE OR REPLACE FUNCTION app.device__scope__organization(
  _target_device uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT t.organization_id IN (
    SELECT organization_id FROM app.get_admin_organizations()
  )
  FROM device.client_device_assignment a
  JOIN client.client c ON a.client_id = c.id
  JOIN team.team t ON c.team_id = t.id
  WHERE a.device_id = _target_device;
$$;

CREATE OR REPLACE FUNCTION app.device__scope__team(
  _target_device uuid,
  _operation text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT c.team_id IN (
    SELECT team_id FROM app.get_member_or_admin_teams()
  )
  FROM device.client_device_assignment a
  JOIN client.client c ON a.client_id = c.id
  WHERE a.device_id = _target_device;
$$;



-- migrate:down

DROP FUNCTION IF EXISTS app.device__scope__team(uuid, text);
DROP FUNCTION IF EXISTS app.device__scope__organization(uuid, text);
DROP FUNCTION IF EXISTS app.device__scope__self(uuid, text);
DROP FUNCTION IF EXISTS app.client_device_assignment__scope__team(uuid, text);
DROP FUNCTION IF EXISTS app.client_device_assignment__scope__organization(uuid, text);
DROP FUNCTION IF EXISTS app.client_device_assignment__scope__self(uuid, text);
DROP FUNCTION IF EXISTS app.client__scope__team(uuid, text);
DROP FUNCTION IF EXISTS app.client__scope__organization(uuid, text);
DROP FUNCTION IF EXISTS app.client__scope__self(uuid, text);
DROP FUNCTION IF EXISTS app.app_user_client_membership__scope__self(uuid, uuid, text);
DROP FUNCTION IF EXISTS app.team__scope__organization(uuid, text);
DROP FUNCTION IF EXISTS app.team__scope__self(uuid, text);
DROP FUNCTION IF EXISTS app.app_user_team_membership__scope__team(uuid, uuid, text);
DROP FUNCTION IF EXISTS app.app_user_team_membership__scope__organization(uuid, uuid, text);
DROP FUNCTION IF EXISTS app.app_user_team_membership__scope__self(uuid, uuid, text);
DROP FUNCTION IF EXISTS app.organization__scope__self(uuid, text);
DROP FUNCTION IF EXISTS app.app_user_organization_membership__scope__organization(uuid, uuid, text);
DROP FUNCTION IF EXISTS app.app_user_organization_membership__scope__self(uuid, uuid, text);
DROP FUNCTION IF EXISTS app.app_user__scope__team(uuid, text);
DROP FUNCTION IF EXISTS app.app_user__scope__organization(uuid, text);
DROP FUNCTION IF EXISTS app.app_user__scope__self(uuid, text);
DROP FUNCTION IF EXISTS app.identity__scope__self(uuid, text);
