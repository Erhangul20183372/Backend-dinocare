-- migrate:up

-- =========== Constraints for app_user_organization_membership ========== ---

ALTER TABLE app_user_organization_membership
ADD CONSTRAINT chk_member_since_not_future
CHECK (member_since <= now());

ALTER TABLE app_user_organization_membership
ADD CONSTRAINT chk_member_until_after_since
CHECK (member_until IS NULL OR member_until > member_since);

ALTER TABLE app_user_organization_membership
ADD CONSTRAINT chk_role_org_only
CHECK (role IN ('organization_admin', 'organization_member'));

-- =========== Constraints for app_user_team_membership ========== ---

ALTER TABLE app_user_team_membership
ADD CONSTRAINT chk_team_member_since_not_future
CHECK (member_since <= now());

ALTER TABLE app_user_team_membership
ADD CONSTRAINT chk_team_member_until_after_since
CHECK (member_until IS NULL OR member_until > member_since);

ALTER TABLE app_user_team_membership
ADD CONSTRAINT chk_team_role_only
CHECK (role IN ('team_admin', 'team_member'));

-- =========== Constraints for app_user_client_membership ========== ---

ALTER TABLE app_user_client_membership
ADD CONSTRAINT chk_client_member_since_not_future
CHECK (member_since <= now());

ALTER TABLE app_user_client_membership
ADD CONSTRAINT chk_client_member_until_after_since
CHECK (member_until IS NULL OR member_until > member_since);

ALTER TABLE app_user_client_membership
ADD CONSTRAINT chk_client_role_only
CHECK (role = 'client_member');

-- =========== Constraints for app_user_root_membership ========== ---

ALTER TABLE app_user_root_membership
ADD CONSTRAINT chk_root_member_since_not_future
CHECK (member_since <= now());

ALTER TABLE app_user_root_membership
ADD CONSTRAINT chk_root_member_until_after_since
CHECK (member_until IS NULL OR member_until > member_since);

ALTER TABLE app_user_root_membership
ADD CONSTRAINT chk_root_role_only
CHECK (role IN ('app_admin', 'app_member'));

-- =========== Constraints for organisation ========== ---

ALTER TABLE organization
ADD CONSTRAINT domain_format_chk
CHECK (domain ~ '^[A-Za-z0-9.-]+.[A-Za-z]{2,}$');

-- =========== Constraints for team ========== ---

ALTER TABLE team
ADD CONSTRAINT chk_team_color_hex
CHECK (color ~ '^#[0-9A-Fa-f]{6}$');

-- =========== client_device_assignment ========== ---

ALTER TABLE client_device_assignment
ADD CONSTRAINT chk_cda_since_not_future
CHECK (assigned_since <= now());

ALTER TABLE client_device_assignment
ADD CONSTRAINT chk_cda_until_after_since
CHECK (assigned_until IS NULL OR assigned_until > assigned_since);

ALTER TABLE client_device_assignment
ADD CONSTRAINT chk_cda_until_unassigned_link
CHECK (
  (assigned_until IS NULL AND unassigned_by IS NULL) OR
  (assigned_until IS NOT NULL AND unassigned_by IS NOT NULL)
);

ALTER TABLE client_device_assignment
ADD CONSTRAINT ex_cda_no_overlap
EXCLUDE USING gist (
  device_id WITH =,
  tstzrange(assigned_since, COALESCE(assigned_until, 'infinity')) WITH &&
);

-- migrate:down

-- =========== Constraints for app_user_organization_membership ========== ---

ALTER TABLE app_user_organization_membership
DROP CONSTRAINT chk_member_since_not_future;

ALTER TABLE app_user_organization_membership
DROP CONSTRAINT chk_member_until_after_since;

ALTER TABLE app_user_organization_membership
DROP CONSTRAINT chk_role_org_only;

-- =========== Constraints for app_user_team_membership ========== ---

ALTER TABLE app_user_team_membership
DROP CONSTRAINT chk_team_member_since_not_future;

ALTER TABLE app_user_team_membership
DROP CONSTRAINT chk_team_member_until_after_since;

ALTER TABLE app_user_team_membership
DROP CONSTRAINT chk_team_role_only;

-- =========== Constraints for app_user_client_membership ========== ---

ALTER TABLE app_user_client_membership
DROP CONSTRAINT chk_client_member_since_not_future;

ALTER TABLE app_user_client_membership
DROP CONSTRAINT chk_client_member_until_after_since;

ALTER TABLE app_user_client_membership
DROP CONSTRAINT chk_client_role_only;

-- =========== Constraints for app_user_root_membership ========== ---

ALTER TABLE app_user_root_membership
DROP CONSTRAINT chk_root_member_since_not_future;

ALTER TABLE app_user_root_membership
DROP CONSTRAINT chk_root_member_until_after_since;

ALTER TABLE app_user_root_membership
DROP CONSTRAINT chk_root_role_only;

-- =========== Constraints for organisation ========== ---
ALTER TABLE organization
DROP CONSTRAINT domain_format_chk;

-- =========== Constraints for team ========== ---

ALTER TABLE team
DROP CONSTRAINT chk_team_color_hex;

-- =========== client_device_assignment ========== ---

ALTER TABLE client_device_assignment
DROP CONSTRAINT chk_cda_since_not_future;

ALTER TABLE client_device_assignment
DROP CONSTRAINT chk_cda_until_after_since;

ALTER TABLE client_device_assignment
DROP CONSTRAINT chk_cda_until_unassigned_link;

ALTER TABLE client_device_assignment
DROP CONSTRAINT ex_cda_no_overlap;