-- migrate:up

-- AUTH
ALTER TABLE app_user SET SCHEMA auth;
ALTER TABLE identity SET SCHEMA auth;
ALTER TABLE app_user_root_membership SET SCHEMA auth;

-- ORGANIZATION
ALTER TABLE organization SET SCHEMA organization;
ALTER TABLE app_user_organization_membership SET SCHEMA organization;

-- TEAM
ALTER TABLE team SET SCHEMA team;
ALTER TABLE app_user_team_membership SET SCHEMA team;

-- CLIENT
ALTER TABLE client SET SCHEMA client;
ALTER TABLE app_user_client_membership SET SCHEMA client;

-- DEVICE
ALTER TABLE device SET SCHEMA device;
ALTER TABLE device_type SET SCHEMA device;
ALTER TABLE client_device_assignment SET SCHEMA device;

-- migrate:down
ALTER TABLE auth.app_user SET SCHEMA public;
ALTER TABLE auth.identity SET SCHEMA public;
ALTER TABLE auth.app_user_root_membership SET SCHEMA public;

ALTER TABLE organization.organization SET SCHEMA public;
ALTER TABLE organization.app_user_organization_membership SET SCHEMA public;

ALTER TABLE team.team SET SCHEMA public;
ALTER TABLE team.app_user_team_membership SET SCHEMA public;

ALTER TABLE client.client SET SCHEMA public;
ALTER TABLE client.app_user_client_membership SET SCHEMA public;

ALTER TABLE device.device SET SCHEMA public;
ALTER TABLE device.device_type SET SCHEMA public;
ALTER TABLE device.client_device_assignment SET SCHEMA public;
