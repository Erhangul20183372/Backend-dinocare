-- For these tests we'll be using the organization: Zuyderland Zorg
-- organization_admin: 0225f4be-0dd5-4a59-9bb8-a187c4a0390f
-- organization_member: f997d0b9-6210-44df-957a-ba363d338dd0
-- team_admin (Team Heerlen): 952a8a36-a986-4ef6-9d43-fddba534b0ed
-- team_admin (Team Sittard): ee07d2a9-050a-45d1-9db2-59f4a1f809d1
-- team_member (Team Heerlen): 6c08321a-0a5f-4045-a3cd-4888460591a1
-- team_member (Team Sittard): 92b7c8c7-0161-4319-a2b5-a5ca672879c1
-- team_member (Team Heerlen and Sittard): b93ba2d4-ca5c-41ce-8817-f3b9dae568ed

SELECT plan(16);

BEGIN;

--------------
--- INSERT ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT throws_ok(
  $$ INSERT INTO device.device_type (name)
      VALUES ('Test Device Type') $$,
  'new row violates row-level security policy for table "device_type"',
  'organization_admin cannot insert device_type'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT throws_ok(
  $$ INSERT INTO device.device_type (name)
      VALUES ('Test Device Type') $$,
  'new row violates row-level security policy for table "device_type"',
  'organization_member cannot insert device_type'
);

-- 3. team_admin
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT throws_ok(
  $$ INSERT INTO device.device_type (name)
      VALUES ('Test Device Type') $$,
  'new row violates row-level security policy for table "device_type"',
  'team_admin cannot insert device_type'
);

-- 4. team_member
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT throws_ok(
  $$ INSERT INTO device.device_type (name)
      VALUES ('Test Device Type') $$,
  'new row violates row-level security policy for table "device_type"',
  'team_member cannot insert device_type'
);

--------------
--- SELECT ---
--------------

-- 1. organization_admin → all device types
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  'SELECT id FROM device.device_type ORDER BY id',
  'SELECT id FROM device.device_type ORDER BY id',
  'organization_admin sees all device types'
);

-- 2. organization_member → no device types
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is(
  (SELECT count(*) FROM device.device_type),
  0::bigint,
  'organization_member sees no device types'
);

-- 3. team_admin → all device types
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  'SELECT id FROM device.device_type ORDER BY id',
  'SELECT id FROM device.device_type ORDER BY id',
  'team_admin sees all device types'
);

-- 4. team_member → all device types
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT results_eq(
  'SELECT id FROM device.device_type ORDER BY id',
  'SELECT id FROM device.device_type ORDER BY id',
  'team_member sees all device types'
);

--------------
--- UPDATE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ UPDATE device.device_type
      SET name = 'Updated Device Type'
      WHERE id = '01c56599-568e-4d2f-9dac-48efcf07e556' 
      RETURNING id::text $$,
  'organization_admin cannot update device_type'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ UPDATE device.device_type
      SET name = 'Updated Device Type'
      WHERE id = '01c56599-568e-4d2f-9dac-48efcf07e556' 
      RETURNING id::text $$,
  'organization_member cannot update device_type'
);

-- 3. team_admin
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ UPDATE device.device_type
      SET name = 'Updated Device Type'
      WHERE id = '01c56599-568e-4d2f-9dac-48efcf07e556' 
      RETURNING id::text $$,
  'team_admin cannot update device_type'
);

-- 4. team_member
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ UPDATE device.device_type
      SET name = 'Updated Device Type'
      WHERE id = '01c56599-568e-4d2f-9dac-48efcf07e556' 
      RETURNING id::text $$,
  'team_member cannot update device_type'
);

--------------
--- DELETE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ DELETE FROM device.device_type
      WHERE id = '01c56599-568e-4d2f-9dac-48efcf07e556'
      RETURNING id::text $$,
  'organization_admin cannot delete device_type'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ DELETE FROM device.device_type
      WHERE id = '01c56599-568e-4d2f-9dac-48efcf07e556'
      RETURNING id::text $$,
  'organization_member cannot delete device_type'
);

-- 3. team_admin
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ DELETE FROM device.device_type
      WHERE id = '01c56599-568e-4d2f-9dac-48efcf07e556'
      RETURNING id::text $$,
  'team_admin cannot delete device_type'
);

-- 4. team_member
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ DELETE FROM device.device_type
      WHERE id = '01c56599-568e-4d2f-9dac-48efcf07e556'
      RETURNING id::text $$,
  'team_member cannot delete device_type'
);

SELECT * FROM finish();

ROLLBACK;