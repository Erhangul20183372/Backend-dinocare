-- migrate:up

ALTER TABLE auth.app_user
  DROP CONSTRAINT app_user_archived_by_fkey;

ALTER TABLE auth.app_user_root_membership
  DROP CONSTRAINT app_user_root_membership_archived_by_fkey,
  DROP CONSTRAINT app_user_root_membership_invited_by_fkey;

ALTER TABLE client.client
  DROP CONSTRAINT client_archived_by_fkey;

ALTER TABLE client.app_user_client_membership
  DROP CONSTRAINT app_user_client_membership_archived_by_fkey,
  DROP CONSTRAINT app_user_client_membership_invited_by_fkey;

ALTER TABLE device.client_device_assignment
  DROP CONSTRAINT client_device_assignment_assigned_by_fkey,
  DROP CONSTRAINT client_device_assignment_unassigned_by_fkey;

ALTER TABLE organization.organization
  DROP CONSTRAINT organization_archived_by_fkey;

ALTER TABLE organization.app_user_organization_membership
  DROP CONSTRAINT app_user_organization_membership_archived_by_fkey,
  DROP CONSTRAINT app_user_organization_membership_invited_by_fkey;

ALTER TABLE team.team
  DROP CONSTRAINT team_archived_by_fkey;

ALTER TABLE team.app_user_team_membership
  DROP CONSTRAINT app_user_team_membership_archived_by_fkey,
  DROP CONSTRAINT app_user_team_membership_invited_by_fkey;


-- migrate:down

ALTER TABLE auth.app_user
  ADD CONSTRAINT app_user_archived_by_fkey
    FOREIGN KEY (archived_by) REFERENCES auth.app_user(id);

ALTER TABLE auth.app_user_root_membership
  ADD CONSTRAINT app_user_root_membership_archived_by_fkey
    FOREIGN KEY (archived_by) REFERENCES auth.app_user(id),
  ADD CONSTRAINT app_user_root_membership_invited_by_fkey
    FOREIGN KEY (invited_by) REFERENCES auth.app_user(id);

ALTER TABLE client.client
  ADD CONSTRAINT client_archived_by_fkey
    FOREIGN KEY (archived_by) REFERENCES auth.app_user(id);

ALTER TABLE client.app_user_client_membership
  ADD CONSTRAINT app_user_client_membership_archived_by_fkey
    FOREIGN KEY (archived_by) REFERENCES auth.app_user(id),
  ADD CONSTRAINT app_user_client_membership_invited_by_fkey
    FOREIGN KEY (invited_by) REFERENCES auth.app_user(id);

ALTER TABLE device.client_device_assignment
  ADD CONSTRAINT client_device_assignment_assigned_by_fkey
    FOREIGN KEY (assigned_by) REFERENCES auth.app_user(id),
  ADD CONSTRAINT client_device_assignment_unassigned_by_fkey
    FOREIGN KEY (unassigned_by) REFERENCES auth.app_user(id);

ALTER TABLE organization.organization
  ADD CONSTRAINT organization_archived_by_fkey
    FOREIGN KEY (archived_by) REFERENCES auth.app_user(id);

ALTER TABLE organization.app_user_organization_membership
  ADD CONSTRAINT app_user_organization_membership_archived_by_fkey
    FOREIGN KEY (archived_by) REFERENCES auth.app_user(id),
  ADD CONSTRAINT app_user_organization_membership_invited_by_fkey
    FOREIGN KEY (invited_by) REFERENCES auth.app_user(id);

ALTER TABLE team.team
  ADD CONSTRAINT team_archived_by_fkey
    FOREIGN KEY (archived_by) REFERENCES auth.app_user(id);

ALTER TABLE team.app_user_team_membership
  ADD CONSTRAINT app_user_team_membership_archived_by_fkey
    FOREIGN KEY (archived_by) REFERENCES auth.app_user(id),
  ADD CONSTRAINT app_user_team_membership_invited_by_fkey
    FOREIGN KEY (invited_by) REFERENCES auth.app_user(id);
