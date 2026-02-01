-- migrate:up
ALTER TABLE organization.app_user_organization_membership
DROP CONSTRAINT app_user_organization_membership_app_user_id_key;

-- migrate:down

ALTER TABLE organization.app_user_organization_membership
ADD CONSTRAINT app_user_organization_membership_app_user_id_key UNIQUE (app_user_id);