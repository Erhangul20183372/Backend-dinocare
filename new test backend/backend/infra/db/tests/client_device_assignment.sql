-- For these tests we'll be using the organization: Zuyderland Zorg
-- organization_admin: 0225f4be-0dd5-4a59-9bb8-a187c4a0390f
-- organization_member: f997d0b9-6210-44df-957a-ba363d338dd0
-- team_admin (Team Heerlen): 952a8a36-a986-4ef6-9d43-fddba534b0ed
-- team_admin (Team Sittard): ee07d2a9-050a-45d1-9db2-59f4a1f809d1
-- team_member (Team Heerlen): 6c08321a-0a5f-4045-a3cd-4888460591a1
-- team_member (Team Sittard): 92b7c8c7-0161-4319-a2b5-a5ca672879c1
-- team_member (Team Heerlen and Sittard): b93ba2d4-ca5c-41ce-8817-f3b9dae568ed

SELECT plan(40);

--------------
--- INSERT ---
--------------

BEGIN;
-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT lives_ok(
  $$ INSERT INTO device.client_device_assignment (device_id, client_id, assigned_by)
      VALUES ('0a153975-12d4-456e-90cf-5e0fc857bdbf', 'e8dacbe0-647d-4642-a808-97bcb6573659', '0225f4be-0dd5-4a59-9bb8-a187c4a0390f') $$,
  'organization_admin can insert client_device_assignment on a client within the organization'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT throws_ok(
  $$ INSERT INTO device.client_device_assignment (device_id, client_id, assigned_by)
      VALUES ('0a153975-12d4-456e-90cf-5e0fc857bdbf', '01a4b588-79a4-4f8a-a30a-390fce380e83', '0225f4be-0dd5-4a59-9bb8-a187c4a0390f') $$,
  'new row violates row-level security policy for table "client_device_assignment"',
  'organization_admin cannot insert client_device_assignment on a client outside their organization'
);
ROLLBACK;

BEGIN;
-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT throws_ok(
  $$ INSERT INTO device.client_device_assignment (device_id, client_id)
      VALUES ('0a153975-12d4-456e-90cf-5e0fc857bdbf', 'e8dacbe0-647d-4642-a808-97bcb6573659') $$,
  'new row violates row-level security policy for table "client_device_assignment"',
  'organization_member cannot insert client_device_assignment'
);
ROLLBACK;

BEGIN;
-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT lives_ok(
  $$ INSERT INTO device.client_device_assignment (device_id, client_id, assigned_by)
      VALUES ('0a153975-12d4-456e-90cf-5e0fc857bdbf', 'a3871686-bc06-4cb6-996d-b3453e5df0a5', '952a8a36-a986-4ef6-9d43-fddba534b0ed') $$,
  'team_admin Heerlen can insert client_device_assignment for their team'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT throws_ok(
  $$ INSERT INTO device.client_device_assignment (device_id, client_id, assigned_by)
      VALUES ('0a153975-12d4-456e-90cf-5e0fc857bdbf', '01a4b588-79a4-4f8a-a30a-390fce380e83', '952a8a36-a986-4ef6-9d43-fddba534b0ed') $$,
  'new row violates row-level security policy for table "client_device_assignment"',
  'team_admin Heerlen cannot insert client_device_assignment for other team'
);
ROLLBACK;

BEGIN;
-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT lives_ok(
  $$ INSERT INTO device.client_device_assignment (device_id, client_id, assigned_by)
      VALUES ('0a153975-12d4-456e-90cf-5e0fc857bdbf', '8d60e42d-016a-4b08-9610-d6b58b092c1b', 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1') $$,
  'team_admin Sittard can insert client_device_assignment for their team'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT throws_ok(
  $$ INSERT INTO device.client_device_assignment (device_id, client_id, assigned_by)
      VALUES ('0a153975-12d4-456e-90cf-5e0fc857bdbf', 'e39c3f9c-e633-4ad9-96dd-c48e8782f194', 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1') $$,
  'new row violates row-level security policy for table "client_device_assignment"',
  'team_admin Sittard cannot insert client_device_assignment for other team'
);
ROLLBACK;

BEGIN;
-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT lives_ok(
  $$ INSERT INTO device.client_device_assignment (device_id, client_id, assigned_by)
      VALUES ('0a153975-12d4-456e-90cf-5e0fc857bdbf', 'a3871686-bc06-4cb6-996d-b3453e5df0a5', '6c08321a-0a5f-4045-a3cd-4888460591a1') $$,
  'team_member Heerlen can insert client_device_assignment for their team'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT throws_ok(
  $$ INSERT INTO device.client_device_assignment (device_id, client_id, assigned_by)
      VALUES ('0a153975-12d4-456e-90cf-5e0fc857bdbf', '01a4b588-79a4-4f8a-a30a-390fce380e83', '6c08321a-0a5f-4045-a3cd-4888460591a1') $$,
  'new row violates row-level security policy for table "client_device_assignment"',
  'team_member Heerlen cannot insert client_device_assignment for other team'
);
ROLLBACK;

BEGIN;
-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT lives_ok(
  $$ INSERT INTO device.client_device_assignment (device_id, client_id, assigned_by)
      VALUES ('0a153975-12d4-456e-90cf-5e0fc857bdbf', '8d60e42d-016a-4b08-9610-d6b58b092c1b', '92b7c8c7-0161-4319-a2b5-a5ca672879c1') $$,
  'team_member Sittard can insert client_device_assignment for their team'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT throws_ok(
  $$ INSERT INTO device.client_device_assignment (device_id, client_id, assigned_by)
      VALUES ('0a153975-12d4-456e-90cf-5e0fc857bdbf', '01a4b588-79a4-4f8a-a30a-390fce380e83', '92b7c8c7-0161-4319-a2b5-a5ca672879c1') $$,
      'new row violates row-level security policy for table "client_device_assignment"',
  'team_member Sittard cannot insert client_device_assignment for other team'
);
ROLLBACK;

BEGIN;
-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT lives_ok(
  $$ INSERT INTO device.client_device_assignment (device_id, client_id, assigned_by)
      VALUES ('0a153975-12d4-456e-90cf-5e0fc857bdbf', 'e8dacbe0-647d-4642-a808-97bcb6573659', '0225f4be-0dd5-4a59-9bb8-a187c4a0390f') $$,
  'team_member Heerlen + Sittard can insert client_device_assignment on a client within the organization'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT throws_ok(
  $$ INSERT INTO device.client_device_assignment (device_id, client_id, assigned_by)
      VALUES ('0a153975-12d4-456e-90cf-5e0fc857bdbf', '01a4b588-79a4-4f8a-a30a-390fce380e83', '0225f4be-0dd5-4a59-9bb8-a187c4a0390f') $$,
  'new row violates row-level security policy for table "client_device_assignment"',
  'team_member Heerlen + Sittard cannot insert client_device_assignment on a client outside their organization'
);
ROLLBACK;

--------------
--- SELECT ---
--------------

BEGIN;
-- 1. org_admin → all assignments in their org
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  'SELECT device_id, client_id FROM device.client_device_assignment ORDER BY device_id, client_id',
  'SELECT a.device_id, a.client_id
     FROM device.client_device_assignment a
     JOIN client.client c ON a.client_id = c.id
     JOIN team.team t ON c.team_id = t.id
    WHERE t.organization_id = (
      SELECT organization_id
      FROM organization.app_user_organization_membership
      WHERE app_user_id = ''0225f4be-0dd5-4a59-9bb8-a187c4a0390f''
      AND role = ''organization_admin''
    )
    ORDER BY a.device_id, a.client_id',
  'org_admin sees all device assignments in their organization'
);

-- 2. org_member → sees nothing
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is((SELECT count(*) FROM device.client_device_assignment), 0::bigint, 'org_member sees no device assignments');

-- 3. team_admin Heerlen → all assignments in their team(s)
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  'SELECT device_id, client_id FROM device.client_device_assignment ORDER BY device_id, client_id',
  'SELECT a.device_id, a.client_id
     FROM device.client_device_assignment a
     JOIN client.client c ON a.client_id = c.id
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''952a8a36-a986-4ef6-9d43-fddba534b0ed''
    ORDER BY a.device_id, a.client_id',
  'team_admin Heerlen sees all assignments in their teams'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT results_eq(
  'SELECT device_id, client_id FROM device.client_device_assignment ORDER BY device_id, client_id',
  'SELECT a.device_id, a.client_id
     FROM device.client_device_assignment a
     JOIN client.client c ON a.client_id = c.id
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''ee07d2a9-050a-45d1-9db2-59f4a1f809d1''
    ORDER BY a.device_id, a.client_id',
  'team_admin Sittard sees all assignments in their teams'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT results_eq(
  'SELECT device_id, client_id FROM device.client_device_assignment ORDER BY device_id, client_id',
  'SELECT a.device_id, a.client_id
     FROM device.client_device_assignment a
     JOIN client.client c ON a.client_id = c.id
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''6c08321a-0a5f-4045-a3cd-4888460591a1''
    ORDER BY a.device_id, a.client_id',
  'team_member Heerlen sees all assignments in their teams'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT results_eq(
  'SELECT device_id, client_id FROM device.client_device_assignment ORDER BY device_id, client_id',
  'SELECT a.device_id, a.client_id
     FROM device.client_device_assignment a
     JOIN client.client c ON a.client_id = c.id
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''92b7c8c7-0161-4319-a2b5-a5ca672879c1''
    ORDER BY a.device_id, a.client_id',
  'team_member Sittard sees all assignments in their teams'
);

-- 7. multi-team member Heerlen+Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT results_eq(
  'SELECT device_id, client_id FROM device.client_device_assignment ORDER BY device_id, client_id',
  'SELECT a.device_id, a.client_id
     FROM device.client_device_assignment a
     JOIN client.client c ON a.client_id = c.id
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''b93ba2d4-ca5c-41ce-8817-f3b9dae568ed''
    ORDER BY a.device_id, a.client_id',
  'multi-team member sees all assignments in both teams'
);
ROLLBACK;

--------------
--- UPDATE ---
--------------

BEGIN;
-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  $$ UPDATE device.client_device_assignment
       SET unassigned_by = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f',
           assigned_until = now()
     WHERE device_id = '42904f79-9e6e-4bf9-ba19-f4a1024b32bb'
     AND client_id = '8d60e42d-016a-4b08-9610-d6b58b092c1b'
     AND unassigned_by IS NULL
     AND assigned_until IS NULL
     RETURNING unassigned_by::text $$,
  $$ SELECT '0225f4be-0dd5-4a59-9bb8-a187c4a0390f' $$,
  'organization_admin can update (unassign) a device assignment in their organization'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ UPDATE device.client_device_assignment
       SET unassigned_by = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f',
           assigned_until = now()
     WHERE device_id = 'db7ae9e6-a3f3-43aa-8a97-2f796955e951'
     AND client_id = '1f08397e-6a06-495d-9aca-924b87113435'
     AND unassigned_by IS NULL
     AND assigned_until IS NULL
     RETURNING device_id $$,
  'organization_admin cannot update (unassign) a device assignment outside their organization'
);
ROLLBACK;

BEGIN;
-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ UPDATE device.client_device_assignment
       SET unassigned_by = 'f997d0b9-6210-44df-957a-ba363d338dd0',
           assigned_until = now()
     WHERE device_id = '42904f79-9e6e-4bf9-ba19-f4a1024b32bb'
     AND client_id = '8d60e42d-016a-4b08-9610-d6b58b092c1b'
     AND unassigned_by IS NULL
     AND assigned_until IS NULL
     RETURNING device_id $$,
  'organization_member cannot update a device assignment'
);
ROLLBACK;

BEGIN;
-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  $$ UPDATE device.client_device_assignment
       SET unassigned_by = '952a8a36-a986-4ef6-9d43-fddba534b0ed',
           assigned_until = now()
     WHERE device_id = '42904f79-9e6e-4bf9-ba19-f4a1024b32bb'
     AND client_id = '8d60e42d-016a-4b08-9610-d6b58b092c1b'
     AND unassigned_by IS NULL
     AND assigned_until IS NULL
     RETURNING unassigned_by::text $$,
  $$ SELECT '952a8a36-a986-4ef6-9d43-fddba534b0ed' $$,
  'team_admin Heerlen can update (unassign) a device assignment in their organization'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ UPDATE device.client_device_assignment
       SET unassigned_by = '952a8a36-a986-4ef6-9d43-fddba534b0ed',
           assigned_until = now()
     WHERE device_id = 'db7ae9e6-a3f3-43aa-8a97-2f796955e951'
     AND client_id = '1f08397e-6a06-495d-9aca-924b87113435'
     AND unassigned_by IS NULL
     AND assigned_until IS NULL
     RETURNING device_id $$,
  'team_admin Heerlen cannot update (unassign) a device assignment outside their organization'
);
ROLLBACK;

BEGIN;
-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT results_eq(
  $$ UPDATE device.client_device_assignment
       SET unassigned_by = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1',
           assigned_until = now()
     WHERE device_id = '42904f79-9e6e-4bf9-ba19-f4a1024b32bb'
     AND client_id = '8d60e42d-016a-4b08-9610-d6b58b092c1b'
     AND unassigned_by IS NULL
     AND assigned_until IS NULL
     RETURNING unassigned_by::text $$,
  $$ SELECT 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1' $$,
  'team_admin Sittard can update (unassign) a device assignment in their organization'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ UPDATE device.client_device_assignment
       SET unassigned_by = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1',
           assigned_until = now()
     WHERE device_id = 'db7ae9e6-a3f3-43aa-8a97-2f796955e951'
     AND client_id = '1f08397e-6a06-495d-9aca-924b87113435'
     AND unassigned_by IS NULL
     AND assigned_until IS NULL
     RETURNING device_id $$,
  'team_admin Sittard cannot update (unassign) a device assignment outside their organization'
);
ROLLBACK;

BEGIN;
-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT results_eq(
  $$ UPDATE device.client_device_assignment
       SET unassigned_by = '6c08321a-0a5f-4045-a3cd-4888460591a1',
           assigned_until = now()
     WHERE device_id = '5c3eed06-c591-47eb-945a-4aa7bb93223b'
     AND client_id = 'db945003-8385-4be2-a296-13cae974c8a6'
     AND unassigned_by IS NULL
     AND assigned_until IS NULL
     RETURNING unassigned_by::text $$,
  $$ SELECT '6c08321a-0a5f-4045-a3cd-4888460591a1' $$,
  'team_member Heerlen can update (unassign) a device assignment in their organization'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ UPDATE device.client_device_assignment
       SET unassigned_by = '6c08321a-0a5f-4045-a3cd-4888460591a1',
           assigned_until = now()
     WHERE device_id = '42904f79-9e6e-4bf9-ba19-f4a1024b32bb'
     AND client_id = '8d60e42d-016a-4b08-9610-d6b58b092c1b'
     AND unassigned_by IS NULL
     AND assigned_until IS NULL
     RETURNING device_id $$,
  'team_member Heerlen cannot update (unassign) a device assignment outside their organization'
);
ROLLBACK;

BEGIN;
-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT results_eq(
  $$ UPDATE device.client_device_assignment
       SET unassigned_by = '92b7c8c7-0161-4319-a2b5-a5ca672879c1',
           assigned_until = now()
     WHERE device_id = '42904f79-9e6e-4bf9-ba19-f4a1024b32bb'
     AND client_id = '8d60e42d-016a-4b08-9610-d6b58b092c1b'
     AND unassigned_by IS NULL
     AND assigned_until IS NULL
     RETURNING unassigned_by::text $$,
  $$ SELECT '92b7c8c7-0161-4319-a2b5-a5ca672879c1' $$,
  'team_member Sittard can update (unassign) a device assignment in their organization'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ UPDATE device.client_device_assignment
       SET unassigned_by = '92b7c8c7-0161-4319-a2b5-a5ca672879c1',
           assigned_until = now()
     WHERE device_id = '5c3eed06-c591-47eb-945a-4aa7bb93223b'
     AND client_id = 'db945003-8385-4be2-a296-13cae974c8a6'
     AND unassigned_by IS NULL
     AND assigned_until IS NULL
     RETURNING device_id $$,
  'team_member Sittard cannot update (unassign) a device assignment outside their organization'
);
ROLLBACK;

BEGIN;
-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT results_eq(
  $$ UPDATE device.client_device_assignment
       SET unassigned_by = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed',
           assigned_until = now()
     WHERE device_id = '42904f79-9e6e-4bf9-ba19-f4a1024b32bb'
     AND client_id = '8d60e42d-016a-4b08-9610-d6b58b092c1b'
     AND unassigned_by IS NULL
     AND assigned_until IS NULL
     RETURNING unassigned_by::text $$,
  $$ SELECT 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed' $$,
  'team_member Heerlen + Sittard can update (unassign) a device assignment in their organization'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ UPDATE device.client_device_assignment
       SET unassigned_by = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed',
           assigned_until = now()
     WHERE device_id = 'db7ae9e6-a3f3-43aa-8a97-2f796955e951'
     AND client_id = '1f08397e-6a06-495d-9aca-924b87113435'
     AND unassigned_by IS NULL
     AND assigned_until IS NULL
     RETURNING device_id $$,
  'team_member Heerlen + Sittard cannot update (unassign) a device assignment outside their organization'
);
ROLLBACK;

--------------
--- DELETE ---
--------------

BEGIN;
-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ DELETE FROM device.client_device_assignment
      WHERE device_id = '1cd180ac-c92a-431b-9751-71f14f521036'
      RETURNING device_id $$,
  'organization_admin delete returns no rows'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ DELETE FROM device.client_device_assignment
      WHERE device_id = '1cd180ac-c92a-431b-9751-71f14f521036'
      RETURNING device_id $$,
  'organization_member cannot delete'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ DELETE FROM device.client_device_assignment
      WHERE device_id = '1cd180ac-c92a-431b-9751-71f14f521036'
      RETURNING device_id $$,
  'team_admin Heerlen cannot delete assignment from another team'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ DELETE FROM device.client_device_assignment
      WHERE device_id = '1cd180ac-c92a-431b-9751-71f14f521036'
      RETURNING device_id $$,
  'team_admin Sittard cannot delete assignment from another team'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ DELETE FROM device.client_device_assignment
      WHERE device_id = '1cd180ac-c92a-431b-9751-71f14f521036'
      RETURNING device_id $$,
  'team_member Heerlen cannot delete'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ DELETE FROM device.client_device_assignment
      WHERE device_id = '1cd180ac-c92a-431b-9751-71f14f521036'
      RETURNING device_id $$,
  'team_member Sittard cannot delete'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ DELETE FROM device.client_device_assignment
      WHERE device_id = '1cd180ac-c92a-431b-9751-71f14f521036'
      RETURNING device_id $$,
  'multi-team member cannot delete'
);

SELECT * FROM finish();

ROLLBACK;
