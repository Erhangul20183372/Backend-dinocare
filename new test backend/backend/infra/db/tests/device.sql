-- For these tests we'll be using the organization: Zuyderland Zorg
-- organization_admin: 0225f4be-0dd5-4a59-9bb8-a187c4a0390f
-- organization_member: f997d0b9-6210-44df-957a-ba363d338dd0
-- team_admin (Team Heerlen): 952a8a36-a986-4ef6-9d43-fddba534b0ed
-- team_admin (Team Sittard): ee07d2a9-050a-45d1-9db2-59f4a1f809d1
-- team_member (Team Heerlen): 6c08321a-0a5f-4045-a3cd-4888460591a1
-- team_member (Team Sittard): 92b7c8c7-0161-4319-a2b5-a5ca672879c1
-- team_member (Team Heerlen and Sittard): b93ba2d4-ca5c-41ce-8817-f3b9dae568ed

SELECT plan(28);

BEGIN;

--------------
--- INSERT ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT throws_ok(
  $$ INSERT INTO device.device (sticker_id) VALUES ('999999'); $$,
  'new row violates row-level security policy for table "device"',
  'organization_admin cannot insert device'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT throws_ok(
  $$ INSERT INTO device.device (sticker_id) VALUES ('999999'); $$,
  'new row violates row-level security policy for table "device"',
  'organization_member cannot insert device'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT throws_ok(
  $$ INSERT INTO device.device (sticker_id) VALUES ('999999'); $$,
  'new row violates row-level security policy for table "device"',
  'team_admin Heerlen cannot insert device'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT throws_ok(
  $$ INSERT INTO device.device (sticker_id) VALUES ('999999'); $$,
  'new row violates row-level security policy for table "device"',
  'team_admin Sittard cannot insert device'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT throws_ok(
  $$ INSERT INTO device.device (sticker_id) VALUES ('999999'); $$,
  'new row violates row-level security policy for table "device"',
  'team_member Heerlen cannot insert device'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT throws_ok(
  $$ INSERT INTO device.device (sticker_id) VALUES ('999999'); $$,
  'new row violates row-level security policy for table "device"',
  'team_member Sittard cannot insert device'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT throws_ok(
  $$ INSERT INTO device.device (sticker_id) VALUES ('999999'); $$,
  'new row violates row-level security policy for table "device"',
  'team_member cannot insert device'
);

--------------
--- SELECT ---
--------------

-- 1. org_admin → all devices in org
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  'SELECT id FROM device.device ORDER BY id',
  'SELECT d.id
     FROM device.device d
     JOIN device.client_device_assignment a ON a.device_id = d.id
     JOIN client.client c ON c.id = a.client_id
     JOIN team.team t ON t.id = c.team_id
    WHERE t.organization_id = (
      SELECT organization_id
        FROM organization.app_user_organization_membership
       WHERE app_user_id = ''0225f4be-0dd5-4a59-9bb8-a187c4a0390f''
    )
   ORDER BY d.id',
  'org_admin sees all devices in their organization'
);

-- 2. org_member → no devices
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is((SELECT count(*) FROM device.device), 0::bigint, 'org_member sees no devices');

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  'SELECT id FROM device.device ORDER BY id',
  'SELECT d.id
     FROM device.device d
     JOIN device.client_device_assignment a ON a.device_id = d.id
     JOIN client.client c ON c.id = a.client_id
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''952a8a36-a986-4ef6-9d43-fddba534b0ed''
   ORDER BY d.id',
  'team_admin Heerlen sees all devices of clients in their teams'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT results_eq(
  'SELECT id FROM device.device ORDER BY id',
  'SELECT d.id
     FROM device.device d
     JOIN device.client_device_assignment a ON a.device_id = d.id
     JOIN client.client c ON c.id = a.client_id
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''ee07d2a9-050a-45d1-9db2-59f4a1f809d1''
   ORDER BY d.id',
  'team_admin Sittard sees all devices of clients in their teams'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT results_eq(
  'SELECT id FROM device.device ORDER BY id',
  'SELECT d.id
     FROM device.device d
     JOIN device.client_device_assignment a ON a.device_id = d.id
     JOIN client.client c ON c.id = a.client_id
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''6c08321a-0a5f-4045-a3cd-4888460591a1''
   ORDER BY d.id',
  'team_member Heerlen sees all devices of clients in their teams'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT results_eq(
  'SELECT id FROM device.device ORDER BY id',
  'SELECT d.id
     FROM device.device d
     JOIN device.client_device_assignment a ON a.device_id = d.id
     JOIN client.client c ON c.id = a.client_id
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''92b7c8c7-0161-4319-a2b5-a5ca672879c1''
   ORDER BY d.id',
  'team_member Sittard sees all devices of clients in their teams'
);

-- 7. multi-team member Heerlen+Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT results_eq(
  'SELECT id FROM device.device ORDER BY id',
  'SELECT d.id
     FROM device.device d
     JOIN device.client_device_assignment a ON a.device_id = d.id
     JOIN client.client c ON c.id = a.client_id
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''b93ba2d4-ca5c-41ce-8817-f3b9dae568ed''
   ORDER BY d.id',
  'multi-team member sees all devices of clients in both teams'
);

--------------
--- UPDATE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ UPDATE device.device
        SET sticker_id = '999999'
      WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211'
      RETURNING sticker_id $$,
  'organization_admin cannot edit a device'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ UPDATE device.device
        SET sticker_id = '999999'
      WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211'
      RETURNING sticker_id $$,
  'organization_member cannot edit a device'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ UPDATE device.device
        SET sticker_id = '999999'
      WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211'
      RETURNING sticker_id $$,
  'team_admin cannot edit a device'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ UPDATE device.device
        SET sticker_id = '999999'
      WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211'
      RETURNING sticker_id $$,
  'team_admin cannot edit a device'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ UPDATE device.device
        SET sticker_id = '999999'
      WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211'
      RETURNING sticker_id $$,
  'team_member cannot edit a device'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ UPDATE device.device
        SET sticker_id = '999999'
      WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211'
      RETURNING sticker_id $$,
  'team_member cannot edit a device'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ UPDATE device.device
        SET sticker_id = '999999'
      WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211'
      RETURNING sticker_id $$,
  'team_member cannot edit a device'
);

--------------
--- DELETE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ DELETE FROM device.device
     WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211' 
     RETURNING id $$,
  'organization_admin cannot delete device'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ DELETE FROM device.device
     WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211' 
     RETURNING id $$,
  'organization_member cannot delete device'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ DELETE FROM device.device
     WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211' 
     RETURNING id $$,
  'team_admin cannot delete device'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ DELETE FROM device.device
     WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211' 
     RETURNING id $$,
  'team_admin cannot delete device'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ DELETE FROM device.device
     WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211' 
     RETURNING id $$,
  'team_member cannot delete device'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ DELETE FROM device.device
     WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211' 
     RETURNING id $$,
  'team_member cannot delete device'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ DELETE FROM device.device
     WHERE id = '4c4633c2-1cc2-47e5-91d3-5bf457fe9211' 
     RETURNING id $$,
  'team_member cannot delete device'
);

SELECT * FROM finish();

ROLLBACK;
