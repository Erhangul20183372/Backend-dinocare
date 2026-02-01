SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: app; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA app;


--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: client; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA client;


--
-- Name: device; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA device;


--
-- Name: organization; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA organization;


--
-- Name: team; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA team;


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: device_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.device_status AS ENUM (
    'active',
    'inactive',
    'retired',
    'in_repair'
);


--
-- Name: gender; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.gender AS ENUM (
    'male',
    'female',
    'other'
);


--
-- Name: role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.role AS ENUM (
    'app_admin',
    'app_member',
    'client_admin',
    'client_member',
    'team_admin',
    'team_member',
    'organization_admin',
    'organization_member'
);


--
-- Name: app_user__scope__organization(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.app_user__scope__organization(_target_user uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
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


--
-- Name: app_user__scope__self(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.app_user__scope__self(_target_user uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT _target_user = app.me();
$$;


--
-- Name: app_user__scope__team(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.app_user__scope__team(_target_user uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
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


--
-- Name: app_user_client_membership__scope__self(uuid, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.app_user_client_membership__scope__self(_target_app_user uuid, _target_client uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT _target_app_user = app.me();
$$;


--
-- Name: app_user_organization_membership__scope__organization(uuid, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.app_user_organization_membership__scope__organization(_target_app_user uuid, _target_organization uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
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


--
-- Name: app_user_organization_membership__scope__self(uuid, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.app_user_organization_membership__scope__self(_target_app_user uuid, _target_organization uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT _target_app_user = app.me();
$$;


--
-- Name: app_user_team_membership__scope__organization(uuid, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.app_user_team_membership__scope__organization(_target_app_user uuid, _target_team uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
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


--
-- Name: app_user_team_membership__scope__self(uuid, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.app_user_team_membership__scope__self(_target_app_user uuid, _target_team uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT _target_app_user = app.me();
$$;


--
-- Name: app_user_team_membership__scope__team(uuid, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.app_user_team_membership__scope__team(_target_app_user uuid, _target_team uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
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


--
-- Name: client__scope__organization(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.client__scope__organization(_target_team uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT _target_team IN (
    SELECT t.id
    FROM team.team t
    WHERE t.organization_id IN (
      SELECT organization_id FROM app.get_admin_organizations()
    )
  );
$$;


--
-- Name: client__scope__self(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.client__scope__self(_target_client uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM client.app_user_client_membership m
    WHERE m.client_id = _target_client
      AND m.app_user_id = app.me()
  );
$$;


--
-- Name: client__scope__team(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.client__scope__team(_target_team uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT _target_team IN (
    SELECT team_id FROM app.get_member_or_admin_teams()
  );
$$;


--
-- Name: client_device_assignment__scope__organization(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.client_device_assignment__scope__organization(_target_client uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
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


--
-- Name: client_device_assignment__scope__self(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.client_device_assignment__scope__self(_target_client uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM client.app_user_client_membership m
    WHERE m.client_id = _target_client
      AND m.app_user_id = app.me()
  );
$$;


--
-- Name: client_device_assignment__scope__team(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.client_device_assignment__scope__team(_target_client uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT c.team_id IN (
    SELECT team_id FROM app.get_member_or_admin_teams()
  )
  FROM client.client c
  WHERE c.id = _target_client;
$$;


--
-- Name: device__scope__organization(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.device__scope__organization(_target_device uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT t.organization_id IN (
    SELECT organization_id FROM app.get_admin_organizations()
  )
  FROM device.client_device_assignment a
  JOIN client.client c ON a.client_id = c.id
  JOIN team.team t ON c.team_id = t.id
  WHERE a.device_id = _target_device;
$$;


--
-- Name: device__scope__self(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.device__scope__self(_target_device uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
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


--
-- Name: device__scope__team(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.device__scope__team(_target_device uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT c.team_id IN (
    SELECT team_id FROM app.get_member_or_admin_teams()
  )
  FROM device.client_device_assignment a
  JOIN client.client c ON a.client_id = c.id
  WHERE a.device_id = _target_device;
$$;


--
-- Name: get_admin_organizations(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.get_admin_organizations() RETURNS TABLE(organization_id uuid)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT organization_id
  FROM organization.app_user_organization_membership
  WHERE app_user_id = app.me() AND role = 'organization_admin'::role
$$;


--
-- Name: get_admin_teams(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.get_admin_teams() RETURNS TABLE(team_id uuid)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT team_id
  FROM team.app_user_team_membership
  WHERE app_user_id = app.me() AND role = 'team_admin'::role
$$;


--
-- Name: get_member_or_admin_teams(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.get_member_or_admin_teams() RETURNS TABLE(team_id uuid)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT team_id
  FROM team.app_user_team_membership
  WHERE app_user_id = app.me() AND (role = 'team_admin'::role OR role = 'team_member'::role)
$$;


--
-- Name: has_client_role(public.role); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.has_client_role(_role public.role) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM client.app_user_client_membership m
    WHERE m.app_user_id = app.me() AND m.role = _role
  );
$$;


--
-- Name: has_org_role(public.role); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.has_org_role(_role public.role) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM organization.app_user_organization_membership m
    WHERE m.app_user_id = app.me() AND m.role = _role
  );
$$;


--
-- Name: has_root_role(public.role); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.has_root_role(_role public.role) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM auth.app_user_root_membership m
    WHERE m.app_user_id = app.me() AND m.role = _role
  );
$$;


--
-- Name: has_team_role(public.role); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.has_team_role(_role public.role) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM team.app_user_team_membership m
    WHERE m.app_user_id = app.me() AND m.role = _role
  );
$$;


--
-- Name: identity__scope__self(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.identity__scope__self(_target_identity uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT _target_identity = u.identity_id
  FROM auth.app_user u
  WHERE u.id = app.me();
$$;


--
-- Name: lookup_app_user(uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.lookup_app_user(_identity_id uuid) RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT u.id
  FROM auth.app_user u
  WHERE u.identity_id = _identity_id;
$$;


--
-- Name: lookup_identity(public.citext); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.lookup_identity(_email public.citext) RETURNS TABLE(id uuid, password_hash text, email_address public.citext)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT id, password_hash, email_address
  FROM auth.identity
  WHERE email_address = _email;
$$;


--
-- Name: me(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.me() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT current_setting('app.current_user_id')::uuid
$$;


--
-- Name: organization__scope__self(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.organization__scope__self(_target_organization uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM organization.app_user_organization_membership m
    WHERE m.organization_id = _target_organization
      AND m.app_user_id = app.me()
  );
$$;


--
-- Name: team__scope__organization(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.team__scope__organization(_target_organization uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT _target_organization IN (
    SELECT organization_id FROM app.get_admin_organizations()
  );
$$;


--
-- Name: team__scope__self(uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.team__scope__self(_target_team uuid, _operation text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_user; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.app_user (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    identity_id uuid NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    archived_on timestamp with time zone,
    archived_by uuid
);


--
-- Name: app_user_root_membership; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.app_user_root_membership (
    app_user_id uuid NOT NULL,
    member_since timestamp with time zone DEFAULT now() NOT NULL,
    invited_by uuid,
    role public.role NOT NULL,
    member_until timestamp with time zone,
    archived_on timestamp with time zone,
    archived_by uuid,
    CONSTRAINT chk_root_member_since_not_future CHECK ((member_since <= now())),
    CONSTRAINT chk_root_member_until_after_since CHECK (((member_until IS NULL) OR (member_until > member_since))),
    CONSTRAINT chk_root_role_only CHECK ((role = ANY (ARRAY['app_admin'::public.role, 'app_member'::public.role])))
);


--
-- Name: identity; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identity (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email_address public.citext NOT NULL,
    password_hash text NOT NULL,
    CONSTRAINT email_format_chk CHECK ((email_address OPERATOR(public.~*) '^[^@\s]+@[^@\s]+.[^@\s]+$'::public.citext))
);


--
-- Name: app_user_client_membership; Type: TABLE; Schema: client; Owner: -
--

CREATE TABLE client.app_user_client_membership (
    app_user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    member_since timestamp with time zone DEFAULT now() NOT NULL,
    invited_by uuid NOT NULL,
    role public.role NOT NULL,
    member_until timestamp with time zone,
    archived_on timestamp with time zone,
    archived_by uuid,
    CONSTRAINT chk_client_member_since_not_future CHECK ((member_since <= now())),
    CONSTRAINT chk_client_member_until_after_since CHECK (((member_until IS NULL) OR (member_until > member_since))),
    CONSTRAINT chk_client_role_only CHECK ((role = 'client_member'::public.role))
);


--
-- Name: client; Type: TABLE; Schema: client; Owner: -
--

CREATE TABLE client.client (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    team_id uuid,
    gender public.gender NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    archived_on timestamp with time zone,
    archived_by uuid
);


--
-- Name: client_device_assignment; Type: TABLE; Schema: device; Owner: -
--

CREATE TABLE device.client_device_assignment (
    client_id uuid NOT NULL,
    device_id uuid NOT NULL,
    assigned_since timestamp with time zone DEFAULT now() NOT NULL,
    assigned_by uuid NOT NULL,
    unassigned_by uuid,
    assigned_until timestamp with time zone,
    device_location text,
    CONSTRAINT chk_cda_since_not_future CHECK ((assigned_since <= now())),
    CONSTRAINT chk_cda_until_after_since CHECK (((assigned_until IS NULL) OR (assigned_until > assigned_since))),
    CONSTRAINT chk_cda_until_unassigned_link CHECK ((((assigned_until IS NULL) AND (unassigned_by IS NULL)) OR ((assigned_until IS NOT NULL) AND (unassigned_by IS NOT NULL))))
);


--
-- Name: device; Type: TABLE; Schema: device; Owner: -
--

CREATE TABLE device.device (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sticker_id text NOT NULL,
    serial_number text NOT NULL,
    device_type_id uuid NOT NULL,
    status public.device_status NOT NULL
);


--
-- Name: device_type; Type: TABLE; Schema: device; Owner: -
--

CREATE TABLE device.device_type (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL
);


--
-- Name: app_user_organization_membership; Type: TABLE; Schema: organization; Owner: -
--

CREATE TABLE organization.app_user_organization_membership (
    organization_id uuid NOT NULL,
    app_user_id uuid NOT NULL,
    member_since timestamp with time zone DEFAULT now() NOT NULL,
    invited_by uuid NOT NULL,
    role public.role NOT NULL,
    member_until timestamp with time zone,
    archived_on timestamp with time zone,
    archived_by uuid,
    CONSTRAINT chk_member_since_not_future CHECK ((member_since <= now())),
    CONSTRAINT chk_member_until_after_since CHECK (((member_until IS NULL) OR (member_until > member_since))),
    CONSTRAINT chk_role_org_only CHECK ((role = ANY (ARRAY['organization_admin'::public.role, 'organization_member'::public.role])))
);


--
-- Name: organization; Type: TABLE; Schema: organization; Owner: -
--

CREATE TABLE organization.organization (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    domain public.citext NOT NULL,
    name text NOT NULL,
    logo_url text,
    archived_on timestamp with time zone,
    archived_by uuid,
    CONSTRAINT domain_format_chk CHECK ((domain OPERATOR(public.~) '^(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$'::public.citext))
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: app_user_team_membership; Type: TABLE; Schema: team; Owner: -
--

CREATE TABLE team.app_user_team_membership (
    app_user_id uuid NOT NULL,
    team_id uuid NOT NULL,
    member_since timestamp with time zone DEFAULT now() NOT NULL,
    invited_by uuid NOT NULL,
    role public.role NOT NULL,
    member_until timestamp with time zone,
    archived_on timestamp with time zone,
    archived_by uuid,
    CONSTRAINT chk_team_member_since_not_future CHECK ((member_since <= now())),
    CONSTRAINT chk_team_member_until_after_since CHECK (((member_until IS NULL) OR (member_until > member_since))),
    CONSTRAINT chk_team_role_only CHECK ((role = ANY (ARRAY['team_admin'::public.role, 'team_member'::public.role])))
);


--
-- Name: team; Type: TABLE; Schema: team; Owner: -
--

CREATE TABLE team.team (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    name text NOT NULL,
    color text NOT NULL,
    archived_on timestamp with time zone,
    archived_by uuid,
    CONSTRAINT chk_team_color_hex CHECK ((color ~ '^#[0-9A-Fa-f]{6}$'::text))
);


--
-- Name: app_user app_user_identity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.app_user
    ADD CONSTRAINT app_user_identity_id_key UNIQUE (identity_id);


--
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- Name: app_user_root_membership app_user_root_membership_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.app_user_root_membership
    ADD CONSTRAINT app_user_root_membership_pkey PRIMARY KEY (app_user_id, member_since);


--
-- Name: identity identity_email_address_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identity
    ADD CONSTRAINT identity_email_address_key UNIQUE (email_address);


--
-- Name: identity identity_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identity
    ADD CONSTRAINT identity_pkey PRIMARY KEY (id);


--
-- Name: app_user_root_membership one_active_root_membership_per_user; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.app_user_root_membership
    ADD CONSTRAINT one_active_root_membership_per_user EXCLUDE USING gist (app_user_id WITH =, ((archived_on IS NULL)) WITH =) WHERE (((archived_on IS NULL) AND (archived_by IS NULL)));


--
-- Name: app_user_client_membership app_user_client_membership_pkey; Type: CONSTRAINT; Schema: client; Owner: -
--

ALTER TABLE ONLY client.app_user_client_membership
    ADD CONSTRAINT app_user_client_membership_pkey PRIMARY KEY (app_user_id, client_id, member_since);


--
-- Name: client client_pkey; Type: CONSTRAINT; Schema: client; Owner: -
--

ALTER TABLE ONLY client.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (id);


--
-- Name: app_user_client_membership one_active_client_membership_per_user_per_client; Type: CONSTRAINT; Schema: client; Owner: -
--

ALTER TABLE ONLY client.app_user_client_membership
    ADD CONSTRAINT one_active_client_membership_per_user_per_client EXCLUDE USING gist (app_user_id WITH =, client_id WITH =) WHERE (((archived_on IS NULL) AND (archived_by IS NULL)));


--
-- Name: client_device_assignment client_device_assignment_pkey; Type: CONSTRAINT; Schema: device; Owner: -
--

ALTER TABLE ONLY device.client_device_assignment
    ADD CONSTRAINT client_device_assignment_pkey PRIMARY KEY (client_id, device_id, assigned_since);


--
-- Name: device device_pkey; Type: CONSTRAINT; Schema: device; Owner: -
--

ALTER TABLE ONLY device.device
    ADD CONSTRAINT device_pkey PRIMARY KEY (id);


--
-- Name: device device_serial_number_key; Type: CONSTRAINT; Schema: device; Owner: -
--

ALTER TABLE ONLY device.device
    ADD CONSTRAINT device_serial_number_key UNIQUE (serial_number);


--
-- Name: device device_sticker_id_key; Type: CONSTRAINT; Schema: device; Owner: -
--

ALTER TABLE ONLY device.device
    ADD CONSTRAINT device_sticker_id_key UNIQUE (sticker_id);


--
-- Name: device_type device_type_name_key; Type: CONSTRAINT; Schema: device; Owner: -
--

ALTER TABLE ONLY device.device_type
    ADD CONSTRAINT device_type_name_key UNIQUE (name);


--
-- Name: device_type device_type_pkey; Type: CONSTRAINT; Schema: device; Owner: -
--

ALTER TABLE ONLY device.device_type
    ADD CONSTRAINT device_type_pkey PRIMARY KEY (id);


--
-- Name: client_device_assignment ex_cda_no_overlap; Type: CONSTRAINT; Schema: device; Owner: -
--

ALTER TABLE ONLY device.client_device_assignment
    ADD CONSTRAINT ex_cda_no_overlap EXCLUDE USING gist (device_id WITH =, tstzrange(assigned_since, COALESCE(assigned_until, 'infinity'::timestamp with time zone)) WITH &&);


--
-- Name: app_user_organization_membership app_user_organization_membership_pkey; Type: CONSTRAINT; Schema: organization; Owner: -
--

ALTER TABLE ONLY organization.app_user_organization_membership
    ADD CONSTRAINT app_user_organization_membership_pkey PRIMARY KEY (organization_id, app_user_id, member_since);


--
-- Name: app_user_organization_membership one_active_org_membership_per_user; Type: CONSTRAINT; Schema: organization; Owner: -
--

ALTER TABLE ONLY organization.app_user_organization_membership
    ADD CONSTRAINT one_active_org_membership_per_user EXCLUDE USING gist (app_user_id WITH =, ((archived_on IS NULL)) WITH =) WHERE (((archived_on IS NULL) AND (archived_by IS NULL)));


--
-- Name: organization organization_domain_key; Type: CONSTRAINT; Schema: organization; Owner: -
--

ALTER TABLE ONLY organization.organization
    ADD CONSTRAINT organization_domain_key UNIQUE (domain);


--
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: organization; Owner: -
--

ALTER TABLE ONLY organization.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: app_user_team_membership app_user_team_membership_pkey; Type: CONSTRAINT; Schema: team; Owner: -
--

ALTER TABLE ONLY team.app_user_team_membership
    ADD CONSTRAINT app_user_team_membership_pkey PRIMARY KEY (app_user_id, team_id, member_since);


--
-- Name: app_user_team_membership one_active_team_membership_per_user_per_team; Type: CONSTRAINT; Schema: team; Owner: -
--

ALTER TABLE ONLY team.app_user_team_membership
    ADD CONSTRAINT one_active_team_membership_per_user_per_team EXCLUDE USING gist (app_user_id WITH =, team_id WITH =) WHERE (((archived_on IS NULL) AND (archived_by IS NULL)));


--
-- Name: team team_organization_id_name_key; Type: CONSTRAINT; Schema: team; Owner: -
--

ALTER TABLE ONLY team.team
    ADD CONSTRAINT team_organization_id_name_key UNIQUE (organization_id, name);


--
-- Name: team team_pkey; Type: CONSTRAINT; Schema: team; Owner: -
--

ALTER TABLE ONLY team.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (id);


--
-- Name: app_user app_user_identity_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.app_user
    ADD CONSTRAINT app_user_identity_id_fkey FOREIGN KEY (identity_id) REFERENCES auth.identity(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: app_user_root_membership app_user_root_membership_app_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.app_user_root_membership
    ADD CONSTRAINT app_user_root_membership_app_user_id_fkey FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: app_user_client_membership app_user_client_membership_app_user_id_fkey; Type: FK CONSTRAINT; Schema: client; Owner: -
--

ALTER TABLE ONLY client.app_user_client_membership
    ADD CONSTRAINT app_user_client_membership_app_user_id_fkey FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: app_user_client_membership app_user_client_membership_client_id_fkey; Type: FK CONSTRAINT; Schema: client; Owner: -
--

ALTER TABLE ONLY client.app_user_client_membership
    ADD CONSTRAINT app_user_client_membership_client_id_fkey FOREIGN KEY (client_id) REFERENCES client.client(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: client client_team_id_fkey; Type: FK CONSTRAINT; Schema: client; Owner: -
--

ALTER TABLE ONLY client.client
    ADD CONSTRAINT client_team_id_fkey FOREIGN KEY (team_id) REFERENCES team.team(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: client_device_assignment client_device_assignment_client_id_fkey; Type: FK CONSTRAINT; Schema: device; Owner: -
--

ALTER TABLE ONLY device.client_device_assignment
    ADD CONSTRAINT client_device_assignment_client_id_fkey FOREIGN KEY (client_id) REFERENCES client.client(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: client_device_assignment client_device_assignment_device_id_fkey; Type: FK CONSTRAINT; Schema: device; Owner: -
--

ALTER TABLE ONLY device.client_device_assignment
    ADD CONSTRAINT client_device_assignment_device_id_fkey FOREIGN KEY (device_id) REFERENCES device.device(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: device device_device_type_id_fkey; Type: FK CONSTRAINT; Schema: device; Owner: -
--

ALTER TABLE ONLY device.device
    ADD CONSTRAINT device_device_type_id_fkey FOREIGN KEY (device_type_id) REFERENCES device.device_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: app_user_organization_membership app_user_organization_membership_app_user_id_fkey; Type: FK CONSTRAINT; Schema: organization; Owner: -
--

ALTER TABLE ONLY organization.app_user_organization_membership
    ADD CONSTRAINT app_user_organization_membership_app_user_id_fkey FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: app_user_organization_membership app_user_organization_membership_organization_id_fkey; Type: FK CONSTRAINT; Schema: organization; Owner: -
--

ALTER TABLE ONLY organization.app_user_organization_membership
    ADD CONSTRAINT app_user_organization_membership_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organization.organization(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: app_user_team_membership app_user_team_membership_app_user_id_fkey; Type: FK CONSTRAINT; Schema: team; Owner: -
--

ALTER TABLE ONLY team.app_user_team_membership
    ADD CONSTRAINT app_user_team_membership_app_user_id_fkey FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: app_user_team_membership app_user_team_membership_team_id_fkey; Type: FK CONSTRAINT; Schema: team; Owner: -
--

ALTER TABLE ONLY team.app_user_team_membership
    ADD CONSTRAINT app_user_team_membership_team_id_fkey FOREIGN KEY (team_id) REFERENCES team.team(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: team team_organization_id_fkey; Type: FK CONSTRAINT; Schema: team; Owner: -
--

ALTER TABLE ONLY team.team
    ADD CONSTRAINT team_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organization.organization(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: app_user; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.app_user ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user_root_membership; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.app_user_root_membership ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user auth_app_user_create; Type: POLICY; Schema: auth; Owner: -
--

CREATE POLICY auth_app_user_create ON auth.app_user FOR INSERT WITH CHECK (app.has_root_role('app_admin'::public.role));


--
-- Name: app_user auth_app_user_delete; Type: POLICY; Schema: auth; Owner: -
--

CREATE POLICY auth_app_user_delete ON auth.app_user FOR DELETE USING (app.has_root_role('app_admin'::public.role));


--
-- Name: app_user auth_app_user_read; Type: POLICY; Schema: auth; Owner: -
--

CREATE POLICY auth_app_user_read ON auth.app_user FOR SELECT USING ((app.has_root_role('app_admin'::public.role) OR app.has_root_role('app_member'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.app_user__scope__organization(id, 'read'::text)) OR (app.has_org_role('organization_member'::public.role) AND app.app_user__scope__self(id, 'read'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.app_user__scope__team(id, 'read'::text)) OR (app.has_team_role('team_member'::public.role) AND app.app_user__scope__self(id, 'read'::text)) OR (app.has_client_role('client_member'::public.role) AND app.app_user__scope__self(id, 'read'::text))));


--
-- Name: app_user_root_membership auth_app_user_root_membership_create; Type: POLICY; Schema: auth; Owner: -
--

CREATE POLICY auth_app_user_root_membership_create ON auth.app_user_root_membership FOR INSERT WITH CHECK (app.has_root_role('app_admin'::public.role));


--
-- Name: app_user_root_membership auth_app_user_root_membership_delete; Type: POLICY; Schema: auth; Owner: -
--

CREATE POLICY auth_app_user_root_membership_delete ON auth.app_user_root_membership FOR DELETE USING (app.has_root_role('app_admin'::public.role));


--
-- Name: app_user_root_membership auth_app_user_root_membership_read; Type: POLICY; Schema: auth; Owner: -
--

CREATE POLICY auth_app_user_root_membership_read ON auth.app_user_root_membership FOR SELECT USING (app.has_root_role('app_admin'::public.role));


--
-- Name: app_user_root_membership auth_app_user_root_membership_update; Type: POLICY; Schema: auth; Owner: -
--

CREATE POLICY auth_app_user_root_membership_update ON auth.app_user_root_membership FOR UPDATE USING (app.has_root_role('app_admin'::public.role)) WITH CHECK (app.has_root_role('app_admin'::public.role));


--
-- Name: app_user auth_app_user_update; Type: POLICY; Schema: auth; Owner: -
--

CREATE POLICY auth_app_user_update ON auth.app_user FOR UPDATE USING ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.app_user__scope__organization(id, 'update'::text)) OR (app.has_org_role('organization_member'::public.role) AND app.app_user__scope__self(id, 'update'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.app_user__scope__self(id, 'update'::text)) OR (app.has_team_role('team_member'::public.role) AND app.app_user__scope__self(id, 'update'::text)) OR (app.has_client_role('client_member'::public.role) AND app.app_user__scope__self(id, 'update'::text)))) WITH CHECK ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.app_user__scope__organization(id, 'update'::text)) OR (app.has_org_role('organization_member'::public.role) AND app.app_user__scope__self(id, 'update'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.app_user__scope__self(id, 'update'::text)) OR (app.has_team_role('team_member'::public.role) AND app.app_user__scope__self(id, 'update'::text)) OR (app.has_client_role('client_member'::public.role) AND app.app_user__scope__self(id, 'update'::text))));


--
-- Name: identity auth_identity_create; Type: POLICY; Schema: auth; Owner: -
--

CREATE POLICY auth_identity_create ON auth.identity FOR INSERT WITH CHECK (app.has_root_role('app_admin'::public.role));


--
-- Name: identity auth_identity_delete; Type: POLICY; Schema: auth; Owner: -
--

CREATE POLICY auth_identity_delete ON auth.identity FOR DELETE USING (app.has_root_role('app_admin'::public.role));


--
-- Name: identity auth_identity_read; Type: POLICY; Schema: auth; Owner: -
--

CREATE POLICY auth_identity_read ON auth.identity FOR SELECT USING ((app.has_root_role('app_admin'::public.role) OR app.has_root_role('app_member'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.identity__scope__self(id, 'read'::text)) OR (app.has_org_role('organization_member'::public.role) AND app.identity__scope__self(id, 'read'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.identity__scope__self(id, 'read'::text)) OR (app.has_team_role('team_member'::public.role) AND app.identity__scope__self(id, 'read'::text)) OR (app.has_client_role('client_member'::public.role) AND app.identity__scope__self(id, 'read'::text))));


--
-- Name: identity auth_identity_update; Type: POLICY; Schema: auth; Owner: -
--

CREATE POLICY auth_identity_update ON auth.identity FOR UPDATE USING ((app.has_root_role('app_admin'::public.role) OR (app.has_root_role('app_member'::public.role) AND app.identity__scope__self(id, 'update'::text)) OR (app.has_org_role('organization_admin'::public.role) AND app.identity__scope__self(id, 'update'::text)) OR (app.has_org_role('organization_member'::public.role) AND app.identity__scope__self(id, 'update'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.identity__scope__self(id, 'update'::text)) OR (app.has_team_role('team_member'::public.role) AND app.identity__scope__self(id, 'update'::text)) OR (app.has_client_role('client_member'::public.role) AND app.identity__scope__self(id, 'update'::text)))) WITH CHECK ((app.has_root_role('app_admin'::public.role) OR (app.has_root_role('app_member'::public.role) AND app.identity__scope__self(id, 'update'::text)) OR (app.has_org_role('organization_admin'::public.role) AND app.identity__scope__self(id, 'update'::text)) OR (app.has_org_role('organization_member'::public.role) AND app.identity__scope__self(id, 'update'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.identity__scope__self(id, 'update'::text)) OR (app.has_team_role('team_member'::public.role) AND app.identity__scope__self(id, 'update'::text)) OR (app.has_client_role('client_member'::public.role) AND app.identity__scope__self(id, 'update'::text))));


--
-- Name: identity; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identity ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user_client_membership; Type: ROW SECURITY; Schema: client; Owner: -
--

ALTER TABLE client.app_user_client_membership ENABLE ROW LEVEL SECURITY;

--
-- Name: client; Type: ROW SECURITY; Schema: client; Owner: -
--

ALTER TABLE client.client ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user_client_membership client_app_user_client_membership_create; Type: POLICY; Schema: client; Owner: -
--

CREATE POLICY client_app_user_client_membership_create ON client.app_user_client_membership FOR INSERT WITH CHECK (app.has_root_role('app_admin'::public.role));


--
-- Name: app_user_client_membership client_app_user_client_membership_delete; Type: POLICY; Schema: client; Owner: -
--

CREATE POLICY client_app_user_client_membership_delete ON client.app_user_client_membership FOR DELETE USING (app.has_root_role('app_admin'::public.role));


--
-- Name: app_user_client_membership client_app_user_client_membership_read; Type: POLICY; Schema: client; Owner: -
--

CREATE POLICY client_app_user_client_membership_read ON client.app_user_client_membership FOR SELECT USING ((app.has_root_role('app_admin'::public.role) OR app.has_root_role('app_member'::public.role) OR (app.has_client_role('client_member'::public.role) AND app.app_user_client_membership__scope__self(app_user_id, client_id, 'read'::text))));


--
-- Name: app_user_client_membership client_app_user_client_membership_update; Type: POLICY; Schema: client; Owner: -
--

CREATE POLICY client_app_user_client_membership_update ON client.app_user_client_membership FOR UPDATE USING (app.has_root_role('app_admin'::public.role)) WITH CHECK (app.has_root_role('app_admin'::public.role));


--
-- Name: client client_client_create; Type: POLICY; Schema: client; Owner: -
--

CREATE POLICY client_client_create ON client.client FOR INSERT WITH CHECK ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.client__scope__organization(team_id, 'create'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.client__scope__team(team_id, 'create'::text)) OR (app.has_team_role('team_member'::public.role) AND app.client__scope__team(team_id, 'create'::text))));


--
-- Name: client client_client_delete; Type: POLICY; Schema: client; Owner: -
--

CREATE POLICY client_client_delete ON client.client FOR DELETE USING (app.has_root_role('app_admin'::public.role));


--
-- Name: client client_client_read; Type: POLICY; Schema: client; Owner: -
--

CREATE POLICY client_client_read ON client.client FOR SELECT USING ((app.has_root_role('app_admin'::public.role) OR app.has_root_role('app_member'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.client__scope__organization(team_id, 'read'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.client__scope__team(team_id, 'read'::text)) OR (app.has_team_role('team_member'::public.role) AND app.client__scope__team(team_id, 'read'::text)) OR (app.has_client_role('client_member'::public.role) AND app.client__scope__self(id, 'read'::text))));


--
-- Name: client client_client_update; Type: POLICY; Schema: client; Owner: -
--

CREATE POLICY client_client_update ON client.client FOR UPDATE USING ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.client__scope__organization(team_id, 'update'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.client__scope__team(team_id, 'update'::text)) OR (app.has_team_role('team_member'::public.role) AND app.client__scope__team(team_id, 'update'::text)))) WITH CHECK ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.client__scope__organization(team_id, 'update'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.client__scope__team(team_id, 'update'::text)) OR (app.has_team_role('team_member'::public.role) AND app.client__scope__team(team_id, 'update'::text))));


--
-- Name: client_device_assignment; Type: ROW SECURITY; Schema: device; Owner: -
--

ALTER TABLE device.client_device_assignment ENABLE ROW LEVEL SECURITY;

--
-- Name: device; Type: ROW SECURITY; Schema: device; Owner: -
--

ALTER TABLE device.device ENABLE ROW LEVEL SECURITY;

--
-- Name: client_device_assignment device_client_device_assignment_create; Type: POLICY; Schema: device; Owner: -
--

CREATE POLICY device_client_device_assignment_create ON device.client_device_assignment FOR INSERT WITH CHECK ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.client_device_assignment__scope__organization(client_id, 'create'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.client_device_assignment__scope__team(client_id, 'create'::text)) OR (app.has_team_role('team_member'::public.role) AND app.client_device_assignment__scope__team(client_id, 'create'::text))));


--
-- Name: client_device_assignment device_client_device_assignment_delete; Type: POLICY; Schema: device; Owner: -
--

CREATE POLICY device_client_device_assignment_delete ON device.client_device_assignment FOR DELETE USING (app.has_root_role('app_admin'::public.role));


--
-- Name: client_device_assignment device_client_device_assignment_read; Type: POLICY; Schema: device; Owner: -
--

CREATE POLICY device_client_device_assignment_read ON device.client_device_assignment FOR SELECT USING ((app.has_root_role('app_admin'::public.role) OR app.has_root_role('app_member'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.client_device_assignment__scope__organization(client_id, 'read'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.client_device_assignment__scope__team(client_id, 'read'::text)) OR (app.has_team_role('team_member'::public.role) AND app.client_device_assignment__scope__team(client_id, 'read'::text)) OR (app.has_client_role('client_member'::public.role) AND app.client_device_assignment__scope__self(client_id, 'read'::text))));


--
-- Name: client_device_assignment device_client_device_assignment_update; Type: POLICY; Schema: device; Owner: -
--

CREATE POLICY device_client_device_assignment_update ON device.client_device_assignment FOR UPDATE USING ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.client_device_assignment__scope__organization(client_id, 'update'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.client_device_assignment__scope__team(client_id, 'update'::text)) OR (app.has_team_role('team_member'::public.role) AND app.client_device_assignment__scope__team(client_id, 'update'::text)))) WITH CHECK ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.client_device_assignment__scope__organization(client_id, 'update'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.client_device_assignment__scope__team(client_id, 'update'::text)) OR (app.has_team_role('team_member'::public.role) AND app.client_device_assignment__scope__team(client_id, 'update'::text))));


--
-- Name: device device_device_create; Type: POLICY; Schema: device; Owner: -
--

CREATE POLICY device_device_create ON device.device FOR INSERT WITH CHECK (app.has_root_role('app_admin'::public.role));


--
-- Name: device device_device_delete; Type: POLICY; Schema: device; Owner: -
--

CREATE POLICY device_device_delete ON device.device FOR DELETE USING (app.has_root_role('app_admin'::public.role));


--
-- Name: device device_device_read; Type: POLICY; Schema: device; Owner: -
--

CREATE POLICY device_device_read ON device.device FOR SELECT USING ((app.has_root_role('app_admin'::public.role) OR app.has_root_role('app_member'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.device__scope__organization(id, 'read'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.device__scope__team(id, 'read'::text)) OR (app.has_team_role('team_member'::public.role) AND app.device__scope__team(id, 'read'::text)) OR (app.has_client_role('client_member'::public.role) AND app.device__scope__self(id, 'read'::text))));


--
-- Name: device_type device_device_type_create; Type: POLICY; Schema: device; Owner: -
--

CREATE POLICY device_device_type_create ON device.device_type FOR INSERT WITH CHECK (app.has_root_role('app_admin'::public.role));


--
-- Name: device_type device_device_type_delete; Type: POLICY; Schema: device; Owner: -
--

CREATE POLICY device_device_type_delete ON device.device_type FOR DELETE USING (app.has_root_role('app_admin'::public.role));


--
-- Name: device_type device_device_type_read; Type: POLICY; Schema: device; Owner: -
--

CREATE POLICY device_device_type_read ON device.device_type FOR SELECT USING ((app.has_root_role('app_admin'::public.role) OR app.has_root_role('app_member'::public.role) OR app.has_org_role('organization_admin'::public.role) OR app.has_team_role('team_admin'::public.role) OR app.has_team_role('team_member'::public.role) OR app.has_client_role('client_member'::public.role)));


--
-- Name: device_type device_device_type_update; Type: POLICY; Schema: device; Owner: -
--

CREATE POLICY device_device_type_update ON device.device_type FOR UPDATE USING (app.has_root_role('app_admin'::public.role)) WITH CHECK (app.has_root_role('app_admin'::public.role));


--
-- Name: device device_device_update; Type: POLICY; Schema: device; Owner: -
--

CREATE POLICY device_device_update ON device.device FOR UPDATE USING (app.has_root_role('app_admin'::public.role)) WITH CHECK (app.has_root_role('app_admin'::public.role));


--
-- Name: device_type; Type: ROW SECURITY; Schema: device; Owner: -
--

ALTER TABLE device.device_type ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user_organization_membership; Type: ROW SECURITY; Schema: organization; Owner: -
--

ALTER TABLE organization.app_user_organization_membership ENABLE ROW LEVEL SECURITY;

--
-- Name: organization; Type: ROW SECURITY; Schema: organization; Owner: -
--

ALTER TABLE organization.organization ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user_organization_membership organization_app_user_organization_membership_create; Type: POLICY; Schema: organization; Owner: -
--

CREATE POLICY organization_app_user_organization_membership_create ON organization.app_user_organization_membership FOR INSERT WITH CHECK (app.has_root_role('app_admin'::public.role));


--
-- Name: app_user_organization_membership organization_app_user_organization_membership_delete; Type: POLICY; Schema: organization; Owner: -
--

CREATE POLICY organization_app_user_organization_membership_delete ON organization.app_user_organization_membership FOR DELETE USING (app.has_root_role('app_admin'::public.role));


--
-- Name: app_user_organization_membership organization_app_user_organization_membership_read; Type: POLICY; Schema: organization; Owner: -
--

CREATE POLICY organization_app_user_organization_membership_read ON organization.app_user_organization_membership FOR SELECT USING ((app.has_root_role('app_admin'::public.role) OR app.has_root_role('app_member'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.app_user_organization_membership__scope__organization(app_user_id, organization_id, 'read'::text)) OR (app.has_org_role('organization_member'::public.role) AND app.app_user_organization_membership__scope__self(app_user_id, organization_id, 'read'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.app_user_organization_membership__scope__self(app_user_id, organization_id, 'read'::text)) OR (app.has_team_role('team_member'::public.role) AND app.app_user_organization_membership__scope__self(app_user_id, organization_id, 'read'::text))));


--
-- Name: app_user_organization_membership organization_app_user_organization_membership_update; Type: POLICY; Schema: organization; Owner: -
--

CREATE POLICY organization_app_user_organization_membership_update ON organization.app_user_organization_membership FOR UPDATE USING ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.app_user_organization_membership__scope__organization(app_user_id, organization_id, 'update'::text)))) WITH CHECK ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.app_user_organization_membership__scope__organization(app_user_id, organization_id, 'update'::text))));


--
-- Name: organization organization_organization_create; Type: POLICY; Schema: organization; Owner: -
--

CREATE POLICY organization_organization_create ON organization.organization FOR INSERT WITH CHECK (app.has_root_role('app_admin'::public.role));


--
-- Name: organization organization_organization_delete; Type: POLICY; Schema: organization; Owner: -
--

CREATE POLICY organization_organization_delete ON organization.organization FOR DELETE USING (app.has_root_role('app_admin'::public.role));


--
-- Name: organization organization_organization_read; Type: POLICY; Schema: organization; Owner: -
--

CREATE POLICY organization_organization_read ON organization.organization FOR SELECT USING ((app.has_root_role('app_admin'::public.role) OR app.has_root_role('app_member'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.organization__scope__self(id, 'read'::text)) OR (app.has_org_role('organization_member'::public.role) AND app.organization__scope__self(id, 'read'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.organization__scope__self(id, 'read'::text)) OR (app.has_team_role('team_member'::public.role) AND app.organization__scope__self(id, 'read'::text))));


--
-- Name: organization organization_organization_update; Type: POLICY; Schema: organization; Owner: -
--

CREATE POLICY organization_organization_update ON organization.organization FOR UPDATE USING ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.organization__scope__self(id, 'update'::text)))) WITH CHECK ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.organization__scope__self(id, 'update'::text))));


--
-- Name: app_user_team_membership; Type: ROW SECURITY; Schema: team; Owner: -
--

ALTER TABLE team.app_user_team_membership ENABLE ROW LEVEL SECURITY;

--
-- Name: team; Type: ROW SECURITY; Schema: team; Owner: -
--

ALTER TABLE team.team ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user_team_membership team_app_user_team_membership_create; Type: POLICY; Schema: team; Owner: -
--

CREATE POLICY team_app_user_team_membership_create ON team.app_user_team_membership FOR INSERT WITH CHECK ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.app_user_team_membership__scope__organization(app_user_id, team_id, 'create'::text))));


--
-- Name: app_user_team_membership team_app_user_team_membership_delete; Type: POLICY; Schema: team; Owner: -
--

CREATE POLICY team_app_user_team_membership_delete ON team.app_user_team_membership FOR DELETE USING (app.has_root_role('app_admin'::public.role));


--
-- Name: app_user_team_membership team_app_user_team_membership_read; Type: POLICY; Schema: team; Owner: -
--

CREATE POLICY team_app_user_team_membership_read ON team.app_user_team_membership FOR SELECT USING ((app.has_root_role('app_admin'::public.role) OR app.has_root_role('app_member'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.app_user_team_membership__scope__organization(app_user_id, team_id, 'read'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.app_user_team_membership__scope__team(app_user_id, team_id, 'read'::text)) OR (app.has_team_role('team_member'::public.role) AND app.app_user_team_membership__scope__self(app_user_id, team_id, 'read'::text))));


--
-- Name: app_user_team_membership team_app_user_team_membership_update; Type: POLICY; Schema: team; Owner: -
--

CREATE POLICY team_app_user_team_membership_update ON team.app_user_team_membership FOR UPDATE USING ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.app_user_team_membership__scope__organization(app_user_id, team_id, 'update'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.app_user_team_membership__scope__team(app_user_id, team_id, 'update'::text)))) WITH CHECK ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.app_user_team_membership__scope__organization(app_user_id, team_id, 'update'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.app_user_team_membership__scope__team(app_user_id, team_id, 'update'::text))));


--
-- Name: team team_team_create; Type: POLICY; Schema: team; Owner: -
--

CREATE POLICY team_team_create ON team.team FOR INSERT WITH CHECK ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.team__scope__organization(organization_id, 'create'::text))));


--
-- Name: team team_team_delete; Type: POLICY; Schema: team; Owner: -
--

CREATE POLICY team_team_delete ON team.team FOR DELETE USING (app.has_root_role('app_admin'::public.role));


--
-- Name: team team_team_read; Type: POLICY; Schema: team; Owner: -
--

CREATE POLICY team_team_read ON team.team FOR SELECT USING ((app.has_root_role('app_admin'::public.role) OR app.has_root_role('app_member'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.team__scope__organization(organization_id, 'read'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.team__scope__self(id, 'read'::text)) OR (app.has_team_role('team_member'::public.role) AND app.team__scope__self(id, 'read'::text))));


--
-- Name: team team_team_update; Type: POLICY; Schema: team; Owner: -
--

CREATE POLICY team_team_update ON team.team FOR UPDATE USING ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.team__scope__organization(organization_id, 'update'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.team__scope__self(id, 'update'::text)))) WITH CHECK ((app.has_root_role('app_admin'::public.role) OR (app.has_org_role('organization_admin'::public.role) AND app.team__scope__organization(organization_id, 'update'::text)) OR (app.has_team_role('team_admin'::public.role) AND app.team__scope__self(id, 'update'::text))));


--
-- PostgreSQL database dump complete
--


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20250904090548'),
    ('20250904125002'),
    ('20250905090230'),
    ('20250905130325'),
    ('20250910111401'),
    ('20250917140156'),
    ('20250922145740'),
    ('20250922161111'),
    ('20250923114053'),
    ('20250929185145'),
    ('20251008210033'),
    ('20251009225319'),
    ('20251010085250');
