-- migrate:up

-- identity deletion restricted if referenced by app_user
ALTER TABLE auth.app_user
  DROP CONSTRAINT app_user_identity_id_fkey,
  ADD CONSTRAINT app_user_identity_id_fkey
    FOREIGN KEY (identity_id) REFERENCES auth.identity(id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

-- app_user deletion cascades to memberships
ALTER TABLE auth.app_user_root_membership
  DROP CONSTRAINT app_user_root_membership_app_user_id_fkey,
  ADD CONSTRAINT app_user_root_membership_app_user_id_fkey
    FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- app_user deletion cascades to memberships
ALTER TABLE client.app_user_client_membership
  DROP CONSTRAINT app_user_client_membership_app_user_id_fkey,
  ADD CONSTRAINT app_user_client_membership_app_user_id_fkey
    FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- client deletion cascades to memberships
ALTER TABLE client.app_user_client_membership
  DROP CONSTRAINT app_user_client_membership_client_id_fkey,
  ADD CONSTRAINT app_user_client_membership_client_id_fkey
    FOREIGN KEY (client_id) REFERENCES client.client(id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- team deletion restricted if referenced by client
ALTER TABLE client.client
  DROP CONSTRAINT client_team_id_fkey,
  ADD CONSTRAINT client_team_id_fkey
    FOREIGN KEY (team_id) REFERENCES team.team(id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

-- client deletion cascades to device assignments
ALTER TABLE device.client_device_assignment
  DROP CONSTRAINT client_device_assignment_client_id_fkey,
  ADD CONSTRAINT client_device_assignment_client_id_fkey
    FOREIGN KEY (client_id) REFERENCES client.client(id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- device deletion restricted if referenced by device assignment
ALTER TABLE device.client_device_assignment
  DROP CONSTRAINT client_device_assignment_device_id_fkey,
  ADD CONSTRAINT client_device_assignment_device_id_fkey
    FOREIGN KEY (device_id) REFERENCES device.device(id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

-- device_type deletion restricted if referenced by device
ALTER TABLE device.device
  DROP CONSTRAINT device_device_type_id_fkey,
  ADD CONSTRAINT device_device_type_id_fkey
    FOREIGN KEY (device_type_id) REFERENCES device.device_type(id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

-- app_user deletion cascades to memberships
ALTER TABLE organization.app_user_organization_membership
  DROP CONSTRAINT app_user_organization_membership_app_user_id_fkey,
  ADD CONSTRAINT app_user_organization_membership_app_user_id_fkey
    FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- organization deletion restricted if referenced by membership
ALTER TABLE organization.app_user_organization_membership
  DROP CONSTRAINT app_user_organization_membership_organization_id_fkey,
  ADD CONSTRAINT app_user_organization_membership_organization_id_fkey
    FOREIGN KEY (organization_id) REFERENCES organization.organization(id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

-- app_user deletion cascades to memberships
ALTER TABLE team.app_user_team_membership
  DROP CONSTRAINT app_user_team_membership_app_user_id_fkey,
  ADD CONSTRAINT app_user_team_membership_app_user_id_fkey
    FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- team deletion restricted if referenced by membership
ALTER TABLE team.app_user_team_membership
  DROP CONSTRAINT app_user_team_membership_team_id_fkey,
  ADD CONSTRAINT app_user_team_membership_team_id_fkey
    FOREIGN KEY (team_id) REFERENCES team.team(id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

-- organization deletion cascades to teams
ALTER TABLE team.team
  DROP CONSTRAINT team_organization_id_fkey,
  ADD CONSTRAINT team_organization_id_fkey
    FOREIGN KEY (organization_id) REFERENCES organization.organization(id)
    ON DELETE CASCADE ON UPDATE CASCADE;


-- migrate:down

ALTER TABLE auth.app_user
  DROP CONSTRAINT app_user_identity_id_fkey,
  ADD CONSTRAINT app_user_identity_id_fkey
    FOREIGN KEY (identity_id) REFERENCES auth.identity(id);

ALTER TABLE auth.app_user_root_membership
  DROP CONSTRAINT app_user_root_membership_app_user_id_fkey,
  ADD CONSTRAINT app_user_root_membership_app_user_id_fkey
    FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id);

ALTER TABLE client.app_user_client_membership
  DROP CONSTRAINT app_user_client_membership_app_user_id_fkey,
  ADD CONSTRAINT app_user_client_membership_app_user_id_fkey
    FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id);

ALTER TABLE client.app_user_client_membership
  DROP CONSTRAINT app_user_client_membership_client_id_fkey,
  ADD CONSTRAINT app_user_client_membership_client_id_fkey
    FOREIGN KEY (client_id) REFERENCES client.client(id);

ALTER TABLE client.client
  DROP CONSTRAINT client_team_id_fkey,
  ADD CONSTRAINT client_team_id_fkey
    FOREIGN KEY (team_id) REFERENCES team.team(id);

ALTER TABLE device.client_device_assignment
  DROP CONSTRAINT client_device_assignment_client_id_fkey,
  ADD CONSTRAINT client_device_assignment_client_id_fkey
    FOREIGN KEY (client_id) REFERENCES client.client(id);

ALTER TABLE device.client_device_assignment
  DROP CONSTRAINT client_device_assignment_device_id_fkey,
  ADD CONSTRAINT client_device_assignment_device_id_fkey
    FOREIGN KEY (device_id) REFERENCES device.device(id);

ALTER TABLE device.device
  DROP CONSTRAINT device_device_type_id_fkey,
  ADD CONSTRAINT device_device_type_id_fkey
    FOREIGN KEY (device_type_id) REFERENCES device.device_type(id);

ALTER TABLE organization.app_user_organization_membership
  DROP CONSTRAINT app_user_organization_membership_app_user_id_fkey,
  ADD CONSTRAINT app_user_organization_membership_app_user_id_fkey
    FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id);

ALTER TABLE organization.app_user_organization_membership
  DROP CONSTRAINT app_user_organization_membership_organization_id_fkey,
  ADD CONSTRAINT app_user_organization_membership_organization_id_fkey
    FOREIGN KEY (organization_id) REFERENCES organization.organization(id);

ALTER TABLE team.app_user_team_membership
  DROP CONSTRAINT app_user_team_membership_app_user_id_fkey,
  ADD CONSTRAINT app_user_team_membership_app_user_id_fkey
    FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id);

ALTER TABLE team.app_user_team_membership
  DROP CONSTRAINT app_user_team_membership_team_id_fkey,
  ADD CONSTRAINT app_user_team_membership_team_id_fkey
    FOREIGN KEY (team_id) REFERENCES team.team(id);

ALTER TABLE team.team
  DROP CONSTRAINT team_organization_id_fkey,
  ADD CONSTRAINT team_organization_id_fkey
    FOREIGN KEY (organization_id) REFERENCES organization.organization(id);
