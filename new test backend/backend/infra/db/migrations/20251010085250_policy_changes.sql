-- migrate:up
DROP POLICY IF EXISTS auth_app_user_root_membership_create ON auth.app_user_root_membership;
        CREATE POLICY auth_app_user_root_membership_create ON auth.app_user_root_membership FOR INSERT
        WITH CHECK ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS auth_app_user_root_membership_read ON auth.app_user_root_membership;
        CREATE POLICY auth_app_user_root_membership_read ON auth.app_user_root_membership FOR SELECT
        USING ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS auth_app_user_root_membership_update ON auth.app_user_root_membership;
        CREATE POLICY auth_app_user_root_membership_update ON auth.app_user_root_membership FOR UPDATE
        USING ((app.has_root_role('app_admin'::role)))
      WITH CHECK ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS auth_app_user_root_membership_delete ON auth.app_user_root_membership;
        CREATE POLICY auth_app_user_root_membership_delete ON auth.app_user_root_membership FOR DELETE
        USING ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS auth_identity_create ON auth.identity;
        CREATE POLICY auth_identity_create ON auth.identity FOR INSERT
        WITH CHECK ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS auth_identity_read ON auth.identity;
        CREATE POLICY auth_identity_read ON auth.identity FOR SELECT
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_root_role('app_member'::role)) OR (app.has_org_role('organization_admin'::role) AND app.identity__scope__self(id, 'read')) OR (app.has_org_role('organization_member'::role) AND app.identity__scope__self(id, 'read')) OR (app.has_team_role('team_admin'::role) AND app.identity__scope__self(id, 'read')) OR (app.has_team_role('team_member'::role) AND app.identity__scope__self(id, 'read')) OR (app.has_client_role('client_member'::role) AND app.identity__scope__self(id, 'read')));
      
        DROP POLICY IF EXISTS auth_identity_update ON auth.identity;
        CREATE POLICY auth_identity_update ON auth.identity FOR UPDATE
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_root_role('app_member'::role) AND app.identity__scope__self(id, 'update')) OR (app.has_org_role('organization_admin'::role) AND app.identity__scope__self(id, 'update')) OR (app.has_org_role('organization_member'::role) AND app.identity__scope__self(id, 'update')) OR (app.has_team_role('team_admin'::role) AND app.identity__scope__self(id, 'update')) OR (app.has_team_role('team_member'::role) AND app.identity__scope__self(id, 'update')) OR (app.has_client_role('client_member'::role) AND app.identity__scope__self(id, 'update')))
      WITH CHECK ((app.has_root_role('app_admin'::role)) OR (app.has_root_role('app_member'::role) AND app.identity__scope__self(id, 'update')) OR (app.has_org_role('organization_admin'::role) AND app.identity__scope__self(id, 'update')) OR (app.has_org_role('organization_member'::role) AND app.identity__scope__self(id, 'update')) OR (app.has_team_role('team_admin'::role) AND app.identity__scope__self(id, 'update')) OR (app.has_team_role('team_member'::role) AND app.identity__scope__self(id, 'update')) OR (app.has_client_role('client_member'::role) AND app.identity__scope__self(id, 'update')));
      
        DROP POLICY IF EXISTS auth_identity_delete ON auth.identity;
        CREATE POLICY auth_identity_delete ON auth.identity FOR DELETE
        USING ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS auth_app_user_create ON auth.app_user;
        CREATE POLICY auth_app_user_create ON auth.app_user FOR INSERT
        WITH CHECK ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS auth_app_user_read ON auth.app_user;
        CREATE POLICY auth_app_user_read ON auth.app_user FOR SELECT
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_root_role('app_member'::role)) OR (app.has_org_role('organization_admin'::role) AND app.app_user__scope__organization(id, 'read')) OR (app.has_org_role('organization_member'::role) AND app.app_user__scope__self(id, 'read')) OR (app.has_team_role('team_admin'::role) AND app.app_user__scope__team(id, 'read')) OR (app.has_team_role('team_member'::role) AND app.app_user__scope__self(id, 'read')) OR (app.has_client_role('client_member'::role) AND app.app_user__scope__self(id, 'read')));
      
        DROP POLICY IF EXISTS auth_app_user_update ON auth.app_user;
        CREATE POLICY auth_app_user_update ON auth.app_user FOR UPDATE
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.app_user__scope__organization(id, 'update')) OR (app.has_org_role('organization_member'::role) AND app.app_user__scope__self(id, 'update')) OR (app.has_team_role('team_admin'::role) AND app.app_user__scope__self(id, 'update')) OR (app.has_team_role('team_member'::role) AND app.app_user__scope__self(id, 'update')) OR (app.has_client_role('client_member'::role) AND app.app_user__scope__self(id, 'update')))
      WITH CHECK ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.app_user__scope__organization(id, 'update')) OR (app.has_org_role('organization_member'::role) AND app.app_user__scope__self(id, 'update')) OR (app.has_team_role('team_admin'::role) AND app.app_user__scope__self(id, 'update')) OR (app.has_team_role('team_member'::role) AND app.app_user__scope__self(id, 'update')) OR (app.has_client_role('client_member'::role) AND app.app_user__scope__self(id, 'update')));
      
        DROP POLICY IF EXISTS auth_app_user_delete ON auth.app_user;
        CREATE POLICY auth_app_user_delete ON auth.app_user FOR DELETE
        USING ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS organization_app_user_organization_membership_create ON organization.app_user_organization_membership;
        CREATE POLICY organization_app_user_organization_membership_create ON organization.app_user_organization_membership FOR INSERT
        WITH CHECK ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS organization_app_user_organization_membership_read ON organization.app_user_organization_membership;
        CREATE POLICY organization_app_user_organization_membership_read ON organization.app_user_organization_membership FOR SELECT
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_root_role('app_member'::role)) OR (app.has_org_role('organization_admin'::role) AND app.app_user_organization_membership__scope__organization(app_user_id, organization_id, 'read')) OR (app.has_org_role('organization_member'::role) AND app.app_user_organization_membership__scope__self(app_user_id, organization_id, 'read')) OR (app.has_team_role('team_admin'::role) AND app.app_user_organization_membership__scope__self(app_user_id, organization_id, 'read')) OR (app.has_team_role('team_member'::role) AND app.app_user_organization_membership__scope__self(app_user_id, organization_id, 'read')));
      
        DROP POLICY IF EXISTS organization_app_user_organization_membership_update ON organization.app_user_organization_membership;
        CREATE POLICY organization_app_user_organization_membership_update ON organization.app_user_organization_membership FOR UPDATE
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.app_user_organization_membership__scope__organization(app_user_id, organization_id, 'update')))
      WITH CHECK ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.app_user_organization_membership__scope__organization(app_user_id, organization_id, 'update')));
      
        DROP POLICY IF EXISTS organization_app_user_organization_membership_delete ON organization.app_user_organization_membership;
        CREATE POLICY organization_app_user_organization_membership_delete ON organization.app_user_organization_membership FOR DELETE
        USING ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS organization_organization_create ON organization.organization;
        CREATE POLICY organization_organization_create ON organization.organization FOR INSERT
        WITH CHECK ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS organization_organization_read ON organization.organization;
        CREATE POLICY organization_organization_read ON organization.organization FOR SELECT
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_root_role('app_member'::role)) OR (app.has_org_role('organization_admin'::role) AND app.organization__scope__self(id, 'read')) OR (app.has_org_role('organization_member'::role) AND app.organization__scope__self(id, 'read')) OR (app.has_team_role('team_admin'::role) AND app.organization__scope__self(id, 'read')) OR (app.has_team_role('team_member'::role) AND app.organization__scope__self(id, 'read')));
      
        DROP POLICY IF EXISTS organization_organization_update ON organization.organization;
        CREATE POLICY organization_organization_update ON organization.organization FOR UPDATE
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.organization__scope__self(id, 'update')))
      WITH CHECK ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.organization__scope__self(id, 'update')));
      
        DROP POLICY IF EXISTS organization_organization_delete ON organization.organization;
        CREATE POLICY organization_organization_delete ON organization.organization FOR DELETE
        USING ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS team_app_user_team_membership_create ON team.app_user_team_membership;
        CREATE POLICY team_app_user_team_membership_create ON team.app_user_team_membership FOR INSERT
        WITH CHECK ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.app_user_team_membership__scope__organization(app_user_id, team_id, 'create')));
      
        DROP POLICY IF EXISTS team_app_user_team_membership_read ON team.app_user_team_membership;
        CREATE POLICY team_app_user_team_membership_read ON team.app_user_team_membership FOR SELECT
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_root_role('app_member'::role)) OR (app.has_org_role('organization_admin'::role) AND app.app_user_team_membership__scope__organization(app_user_id, team_id, 'read')) OR (app.has_team_role('team_admin'::role) AND app.app_user_team_membership__scope__team(app_user_id, team_id, 'read')) OR (app.has_team_role('team_member'::role) AND app.app_user_team_membership__scope__self(app_user_id, team_id, 'read')));
      
        DROP POLICY IF EXISTS team_app_user_team_membership_update ON team.app_user_team_membership;
        CREATE POLICY team_app_user_team_membership_update ON team.app_user_team_membership FOR UPDATE
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.app_user_team_membership__scope__organization(app_user_id, team_id, 'update')) OR (app.has_team_role('team_admin'::role) AND app.app_user_team_membership__scope__team(app_user_id, team_id, 'update')))
      WITH CHECK ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.app_user_team_membership__scope__organization(app_user_id, team_id, 'update')) OR (app.has_team_role('team_admin'::role) AND app.app_user_team_membership__scope__team(app_user_id, team_id, 'update')));
      
        DROP POLICY IF EXISTS team_app_user_team_membership_delete ON team.app_user_team_membership;
        CREATE POLICY team_app_user_team_membership_delete ON team.app_user_team_membership FOR DELETE
        USING ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS team_team_create ON team.team;
        CREATE POLICY team_team_create ON team.team FOR INSERT
        WITH CHECK ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.team__scope__organization(organization_id, 'create')));
      
        DROP POLICY IF EXISTS team_team_read ON team.team;
        CREATE POLICY team_team_read ON team.team FOR SELECT
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_root_role('app_member'::role)) OR (app.has_org_role('organization_admin'::role) AND app.team__scope__organization(organization_id, 'read')) OR (app.has_team_role('team_admin'::role) AND app.team__scope__self(id, 'read')) OR (app.has_team_role('team_member'::role) AND app.team__scope__self(id, 'read')));
      
        DROP POLICY IF EXISTS team_team_update ON team.team;
        CREATE POLICY team_team_update ON team.team FOR UPDATE
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.team__scope__organization(organization_id, 'update')) OR (app.has_team_role('team_admin'::role) AND app.team__scope__self(id, 'update')))
      WITH CHECK ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.team__scope__organization(organization_id, 'update')) OR (app.has_team_role('team_admin'::role) AND app.team__scope__self(id, 'update')));
      
        DROP POLICY IF EXISTS team_team_delete ON team.team;
        CREATE POLICY team_team_delete ON team.team FOR DELETE
        USING ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS client_app_user_client_membership_create ON client.app_user_client_membership;
        CREATE POLICY client_app_user_client_membership_create ON client.app_user_client_membership FOR INSERT
        WITH CHECK ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS client_app_user_client_membership_read ON client.app_user_client_membership;
        CREATE POLICY client_app_user_client_membership_read ON client.app_user_client_membership FOR SELECT
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_root_role('app_member'::role)) OR (app.has_client_role('client_member'::role) AND app.app_user_client_membership__scope__self(app_user_id, client_id, 'read')));
      
        DROP POLICY IF EXISTS client_app_user_client_membership_update ON client.app_user_client_membership;
        CREATE POLICY client_app_user_client_membership_update ON client.app_user_client_membership FOR UPDATE
        USING ((app.has_root_role('app_admin'::role)))
      WITH CHECK ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS client_app_user_client_membership_delete ON client.app_user_client_membership;
        CREATE POLICY client_app_user_client_membership_delete ON client.app_user_client_membership FOR DELETE
        USING ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS client_client_create ON client.client;
        CREATE POLICY client_client_create ON client.client FOR INSERT
        WITH CHECK ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.client__scope__organization(team_id, 'create')) OR (app.has_team_role('team_admin'::role) AND app.client__scope__team(team_id, 'create')) OR (app.has_team_role('team_member'::role) AND app.client__scope__team(team_id, 'create')));
      
        DROP POLICY IF EXISTS client_client_read ON client.client;
        CREATE POLICY client_client_read ON client.client FOR SELECT
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_root_role('app_member'::role)) OR (app.has_org_role('organization_admin'::role) AND app.client__scope__organization(team_id, 'read')) OR (app.has_team_role('team_admin'::role) AND app.client__scope__team(team_id, 'read')) OR (app.has_team_role('team_member'::role) AND app.client__scope__team(team_id, 'read')) OR (app.has_client_role('client_member'::role) AND app.client__scope__self(id, 'read')));
      
        DROP POLICY IF EXISTS client_client_update ON client.client;
        CREATE POLICY client_client_update ON client.client FOR UPDATE
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.client__scope__organization(team_id, 'update')) OR (app.has_team_role('team_admin'::role) AND app.client__scope__team(team_id, 'update')) OR (app.has_team_role('team_member'::role) AND app.client__scope__team(team_id, 'update')))
      WITH CHECK ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.client__scope__organization(team_id, 'update')) OR (app.has_team_role('team_admin'::role) AND app.client__scope__team(team_id, 'update')) OR (app.has_team_role('team_member'::role) AND app.client__scope__team(team_id, 'update')));
      
        DROP POLICY IF EXISTS client_client_delete ON client.client;
        CREATE POLICY client_client_delete ON client.client FOR DELETE
        USING ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS device_client_device_assignment_create ON device.client_device_assignment;
        CREATE POLICY device_client_device_assignment_create ON device.client_device_assignment FOR INSERT
        WITH CHECK ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.client_device_assignment__scope__organization(client_id, 'create')) OR (app.has_team_role('team_admin'::role) AND app.client_device_assignment__scope__team(client_id, 'create')) OR (app.has_team_role('team_member'::role) AND app.client_device_assignment__scope__team(client_id, 'create')));
      
        DROP POLICY IF EXISTS device_client_device_assignment_read ON device.client_device_assignment;
        CREATE POLICY device_client_device_assignment_read ON device.client_device_assignment FOR SELECT
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_root_role('app_member'::role)) OR (app.has_org_role('organization_admin'::role) AND app.client_device_assignment__scope__organization(client_id, 'read')) OR (app.has_team_role('team_admin'::role) AND app.client_device_assignment__scope__team(client_id, 'read')) OR (app.has_team_role('team_member'::role) AND app.client_device_assignment__scope__team(client_id, 'read')) OR (app.has_client_role('client_member'::role) AND app.client_device_assignment__scope__self(client_id, 'read')));
      
        DROP POLICY IF EXISTS device_client_device_assignment_update ON device.client_device_assignment;
        CREATE POLICY device_client_device_assignment_update ON device.client_device_assignment FOR UPDATE
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.client_device_assignment__scope__organization(client_id, 'update')) OR (app.has_team_role('team_admin'::role) AND app.client_device_assignment__scope__team(client_id, 'update')) OR (app.has_team_role('team_member'::role) AND app.client_device_assignment__scope__team(client_id, 'update')))
      WITH CHECK ((app.has_root_role('app_admin'::role)) OR (app.has_org_role('organization_admin'::role) AND app.client_device_assignment__scope__organization(client_id, 'update')) OR (app.has_team_role('team_admin'::role) AND app.client_device_assignment__scope__team(client_id, 'update')) OR (app.has_team_role('team_member'::role) AND app.client_device_assignment__scope__team(client_id, 'update')));
      
        DROP POLICY IF EXISTS device_client_device_assignment_delete ON device.client_device_assignment;
        CREATE POLICY device_client_device_assignment_delete ON device.client_device_assignment FOR DELETE
        USING ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS device_device_create ON device.device;
        CREATE POLICY device_device_create ON device.device FOR INSERT
        WITH CHECK ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS device_device_read ON device.device;
        CREATE POLICY device_device_read ON device.device FOR SELECT
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_root_role('app_member'::role)) OR (app.has_org_role('organization_admin'::role) AND app.device__scope__organization(id, 'read')) OR (app.has_team_role('team_admin'::role) AND app.device__scope__team(id, 'read')) OR (app.has_team_role('team_member'::role) AND app.device__scope__team(id, 'read')) OR (app.has_client_role('client_member'::role) AND app.device__scope__self(id, 'read')));
      
        DROP POLICY IF EXISTS device_device_update ON device.device;
        CREATE POLICY device_device_update ON device.device FOR UPDATE
        USING ((app.has_root_role('app_admin'::role)))
      WITH CHECK ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS device_device_delete ON device.device;
        CREATE POLICY device_device_delete ON device.device FOR DELETE
        USING ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS device_device_type_create ON device.device_type;
        CREATE POLICY device_device_type_create ON device.device_type FOR INSERT
        WITH CHECK ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS device_device_type_read ON device.device_type;
        CREATE POLICY device_device_type_read ON device.device_type FOR SELECT
        USING ((app.has_root_role('app_admin'::role)) OR (app.has_root_role('app_member'::role)) OR (app.has_org_role('organization_admin'::role)) OR (app.has_team_role('team_admin'::role)) OR (app.has_team_role('team_member'::role)) OR (app.has_client_role('client_member'::role)));
      
        DROP POLICY IF EXISTS device_device_type_update ON device.device_type;
        CREATE POLICY device_device_type_update ON device.device_type FOR UPDATE
        USING ((app.has_root_role('app_admin'::role)))
      WITH CHECK ((app.has_root_role('app_admin'::role)));
      
        DROP POLICY IF EXISTS device_device_type_delete ON device.device_type;
        CREATE POLICY device_device_type_delete ON device.device_type FOR DELETE
        USING ((app.has_root_role('app_admin'::role)));

-- migrate:down
DROP POLICY IF EXISTS auth_app_user_root_membership_create ON auth.app_user_root_membership;

DROP POLICY IF EXISTS auth_app_user_root_membership_read ON auth.app_user_root_membership;

DROP POLICY IF EXISTS auth_app_user_root_membership_update ON auth.app_user_root_membership;

DROP POLICY IF EXISTS auth_app_user_root_membership_delete ON auth.app_user_root_membership;

DROP POLICY IF EXISTS auth_identity_create ON auth.identity;

DROP POLICY IF EXISTS auth_identity_read ON auth.identity;

DROP POLICY IF EXISTS auth_identity_update ON auth.identity;

DROP POLICY IF EXISTS auth_identity_delete ON auth.identity;

DROP POLICY IF EXISTS auth_app_user_create ON auth.app_user;

DROP POLICY IF EXISTS auth_app_user_read ON auth.app_user;

DROP POLICY IF EXISTS auth_app_user_update ON auth.app_user;

DROP POLICY IF EXISTS auth_app_user_delete ON auth.app_user;

DROP POLICY IF EXISTS organization_app_user_organization_membership_create ON organization.app_user_organization_membership;

DROP POLICY IF EXISTS organization_app_user_organization_membership_read ON organization.app_user_organization_membership;

DROP POLICY IF EXISTS organization_app_user_organization_membership_update ON organization.app_user_organization_membership;

DROP POLICY IF EXISTS organization_app_user_organization_membership_delete ON organization.app_user_organization_membership;

DROP POLICY IF EXISTS organization_organization_create ON organization.organization;

DROP POLICY IF EXISTS organization_organization_read ON organization.organization;

DROP POLICY IF EXISTS organization_organization_update ON organization.organization;

DROP POLICY IF EXISTS organization_organization_delete ON organization.organization;

DROP POLICY IF EXISTS team_app_user_team_membership_create ON team.app_user_team_membership;

DROP POLICY IF EXISTS team_app_user_team_membership_read ON team.app_user_team_membership;

DROP POLICY IF EXISTS team_app_user_team_membership_update ON team.app_user_team_membership;

DROP POLICY IF EXISTS team_app_user_team_membership_delete ON team.app_user_team_membership;

DROP POLICY IF EXISTS team_team_create ON team.team;

DROP POLICY IF EXISTS team_team_read ON team.team;

DROP POLICY IF EXISTS team_team_update ON team.team;

DROP POLICY IF EXISTS team_team_delete ON team.team;

DROP POLICY IF EXISTS client_app_user_client_membership_create ON client.app_user_client_membership;

DROP POLICY IF EXISTS client_app_user_client_membership_read ON client.app_user_client_membership;

DROP POLICY IF EXISTS client_app_user_client_membership_update ON client.app_user_client_membership;

DROP POLICY IF EXISTS client_app_user_client_membership_delete ON client.app_user_client_membership;

DROP POLICY IF EXISTS client_client_create ON client.client;

DROP POLICY IF EXISTS client_client_read ON client.client;

DROP POLICY IF EXISTS client_client_update ON client.client;

DROP POLICY IF EXISTS client_client_delete ON client.client;

DROP POLICY IF EXISTS device_client_device_assignment_create ON device.client_device_assignment;

DROP POLICY IF EXISTS device_client_device_assignment_read ON device.client_device_assignment;

DROP POLICY IF EXISTS device_client_device_assignment_update ON device.client_device_assignment;

DROP POLICY IF EXISTS device_client_device_assignment_delete ON device.client_device_assignment;

DROP POLICY IF EXISTS device_device_create ON device.device;

DROP POLICY IF EXISTS device_device_read ON device.device;

DROP POLICY IF EXISTS device_device_update ON device.device;

DROP POLICY IF EXISTS device_device_delete ON device.device;

DROP POLICY IF EXISTS device_device_type_create ON device.device_type;

DROP POLICY IF EXISTS device_device_type_read ON device.device_type;

DROP POLICY IF EXISTS device_device_type_update ON device.device_type;

DROP POLICY IF EXISTS device_device_type_delete ON device.device_type;
