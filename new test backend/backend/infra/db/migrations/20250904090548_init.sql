-- migrate:up

CREATE TYPE gender AS ENUM ('male', 'female', 'other');
CREATE TYPE device_status AS ENUM ('active', 'inactive', 'retired', 'in_repair');
CREATE TYPE role AS ENUM (
  'app_admin', 'app_member',
  'client_admin', 'client_member',
  'team_admin', 'team_member',
  'organization_admin', 'organization_member'
);

CREATE TABLE organization (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    logo_url TEXT
);

CREATE TABLE identity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email_address TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL
);

CREATE TABLE app_user (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    identity_id UUID UNIQUE NOT NULL REFERENCES identity(id),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL
);

CREATE TABLE team (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organization(id),
    name TEXT NOT NULL,
    color TEXT NOT NULL,
    is_archived BOOLEAN NOT NULL DEFAULT false,
    UNIQUE (organization_id, name)
);

CREATE TABLE client (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES team(id),
    gender gender NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    is_archived BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE device_type (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE device (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sticker_id TEXT UNIQUE NOT NULL,
    serial_number TEXT UNIQUE NOT NULL,
    device_type_id UUID NOT NULL REFERENCES device_type(id),
    status device_status NOT NULL
);

CREATE TABLE client_device_assignment (
    client_id UUID NOT NULL REFERENCES client(id),
    device_id UUID NOT NULL REFERENCES device(id),
    assigned_since TIMESTAMPTZ NOT NULL,
    assigned_by UUID NOT NULL REFERENCES app_user(id),
    unassigned_by UUID REFERENCES app_user(id),
    assigned_until TIMESTAMPTZ,
    device_location TEXT,
    PRIMARY KEY (client_id, device_id, assigned_since)
);

CREATE TABLE app_user_root_membership (
    app_user_id UUID NOT NULL REFERENCES app_user(id),
    member_since TIMESTAMPTZ NOT NULL,
    invited_by UUID REFERENCES app_user(id),
    role role NOT NULL,
    member_until TIMESTAMPTZ,
    PRIMARY KEY (app_user_id, member_since)
);

CREATE TABLE app_user_organization_membership (
    organization_id UUID NOT NULL REFERENCES organization(id),
    app_user_id UUID NOT NULL UNIQUE REFERENCES app_user(id),
    member_since TIMESTAMPTZ NOT NULL,
    invited_by UUID NOT NULL REFERENCES app_user(id),
    role role NOT NULL,
    member_until TIMESTAMPTZ,
    PRIMARY KEY (organization_id, app_user_id, member_since)
);

CREATE TABLE app_user_team_membership (
    app_user_id UUID NOT NULL REFERENCES app_user(id),
    team_id UUID NOT NULL REFERENCES team(id),
    member_since TIMESTAMPTZ NOT NULL,
    invited_by UUID NOT NULL REFERENCES app_user(id),
    role role NOT NULL,
    member_until TIMESTAMPTZ,
    PRIMARY KEY (app_user_id, team_id, member_since)
);

CREATE TABLE app_user_client_membership (
    app_user_id UUID NOT NULL REFERENCES app_user(id),
    client_id UUID NOT NULL REFERENCES client(id),
    member_since TIMESTAMPTZ NOT NULL,
    invited_by UUID NOT NULL REFERENCES app_user(id),
    role role NOT NULL,
    member_until TIMESTAMPTZ,
    PRIMARY KEY (app_user_id, client_id, member_since)
);

-- migrate:down

DROP TABLE IF EXISTS app_user_client_membership;
DROP TABLE IF EXISTS app_user_team_membership;
DROP TABLE IF EXISTS app_user_organization_membership;
DROP TABLE IF EXISTS app_user_root_membership;
DROP TABLE IF EXISTS client_device_assignment;
DROP TABLE IF EXISTS device;
DROP TABLE IF EXISTS device_type;
DROP TABLE IF EXISTS client;
DROP TABLE IF EXISTS team;
DROP TABLE IF EXISTS app_user;
DROP TABLE IF EXISTS identity;
DROP TABLE IF EXISTS organization;
DROP TYPE IF EXISTS role;
DROP TYPE IF EXISTS device_status;
DROP TYPE IF EXISTS gender;
