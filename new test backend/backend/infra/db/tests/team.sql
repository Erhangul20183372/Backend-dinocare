-- For these tests we'll be using the organization: Zuyderland Zorg
-- organization_admin: 0225f4be-0dd5-4a59-9bb8-a187c4a0390f
-- organization_member: f997d0b9-6210-44df-957a-ba363d338dd0
-- team_admin (Team Heerlen): 952a8a36-a986-4ef6-9d43-fddba534b0ed
-- team_admin (Team Sittard): ee07d2a9-050a-45d1-9db2-59f4a1f809d1
-- team_member (Team Heerlen): 6c08321a-0a5f-4045-a3cd-4888460591a1
-- team_member (Team Sittard): 92b7c8c7-0161-4319-a2b5-a5ca672879c1
-- team_member (Team Heerlen and Sittard): b93ba2d4-ca5c-41ce-8817-f3b9dae568ed

SELECT plan(32);

BEGIN;

--------------
--- INSERT ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT lives_ok(
  $$ INSERT INTO team.team (id, organization_id, name, color)
     VALUES (gen_random_uuid(), '1d17b0d9-5722-4236-8fe9-b173c39a97bb', 'TEAM', '#FFFFFF'); $$,
  'organization_admin can insert team in their organization'
);

SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT throws_ok(
  $$ INSERT INTO team.team (id, organization_id, name, color)
     VALUES (gen_random_uuid(), '0a11114d-1e13-4e2d-ae3c-a0fc94cee5e0', 'TEAM', '#FFFFFF'); $$,
  'new row violates row-level security policy for table "team"',
  'organization_admin cannot insert team in other organizations'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT throws_ok(
  $$ INSERT INTO team.team (id, organization_id, name, color)
     VALUES (gen_random_uuid(), '1d17b0d9-5722-4236-8fe9-b173c39a97bb', 'TEAM', '#FFFFFF'); $$,
  'new row violates row-level security policy for table "team"',
  'team_member cannot insert team'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT throws_ok(
  $$ INSERT INTO team.team (id, organization_id, name, color)
     VALUES (gen_random_uuid(), '1d17b0d9-5722-4236-8fe9-b173c39a97bb', 'TEAM', '#FFFFFF'); $$,
  'new row violates row-level security policy for table "team"',
  'team_admin cannot insert team'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT throws_ok(
  $$ INSERT INTO team.team (id, organization_id, name, color)
     VALUES (gen_random_uuid(), '1d17b0d9-5722-4236-8fe9-b173c39a97bb', 'TEAM', '#FFFFFF'); $$,
  'new row violates row-level security policy for table "team"',
  'team_admin cannot insert team'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT throws_ok(
  $$ INSERT INTO team.team (id, organization_id, name, color)
     VALUES (gen_random_uuid(), '1d17b0d9-5722-4236-8fe9-b173c39a97bb', 'TEAM', '#FFFFFF'); $$,
  'new row violates row-level security policy for table "team"',
  'team_member cannot insert team'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT throws_ok(
  $$ INSERT INTO team.team (id, organization_id, name, color)
     VALUES (gen_random_uuid(), '1d17b0d9-5722-4236-8fe9-b173c39a97bb', 'TEAM', '#FFFFFF'); $$,
  'new row violates row-level security policy for table "team"',
  'team_member cannot insert team'
);

-- 7. multi-team member Heerlen+Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT throws_ok(
  $$ INSERT INTO team.team (id, organization_id, name, color)
     VALUES (gen_random_uuid(), '1d17b0d9-5722-4236-8fe9-b173c39a97bb', 'TEAM', '#FFFFFF'); $$,
  'new row violates row-level security policy for table "team"',
  'multi-team member cannot insert team'
);

--------------
--- SELECT ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  'SELECT id FROM team.team ORDER BY id',
  'SELECT id FROM team.team WHERE organization_id = (
       SELECT organization_id
       FROM organization.app_user_organization_membership
       WHERE app_user_id = ''0225f4be-0dd5-4a59-9bb8-a187c4a0390f''
   ) ORDER BY id',
  'organization_admin sees all teams in their organization'
);

-- 2. organization_member → sees nothing
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is((SELECT count(*) FROM team.team), 0::bigint, 'organization_member sees no teams');

-- 3. team_admin Heerlen (also member in Sittard)
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  'SELECT id FROM team.team ORDER BY id',
  'SELECT t.id
     FROM team.team t
     JOIN team.app_user_team_membership tm ON tm.team_id = t.id
    WHERE tm.app_user_id = ''952a8a36-a986-4ef6-9d43-fddba534b0ed''
   ORDER BY t.id',
  'team_admin Heerlen sees Heerlen as admin and Sittard as member'
);

-- 4. team_admin Sittard (also member in Heerlen)
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT results_eq(
  'SELECT id FROM team.team ORDER BY id',
  'SELECT t.id
     FROM team.team t
     JOIN team.app_user_team_membership tm ON tm.team_id = t.id
    WHERE tm.app_user_id = ''ee07d2a9-050a-45d1-9db2-59f4a1f809d1''
   ORDER BY t.id',
  'team_admin Sittard sees Sittard as admin and Heerlen as member'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT results_eq(
  'SELECT id FROM team.team',
  'SELECT t.id
     FROM team.team t
     JOIN team.app_user_team_membership tm ON tm.team_id = t.id
    WHERE tm.app_user_id = ''6c08321a-0a5f-4045-a3cd-4888460591a1''',
  'team_member Heerlen sees only Heerlen'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT results_eq(
  'SELECT id FROM team.team',
  'SELECT t.id
     FROM team.team t
     JOIN team.app_user_team_membership tm ON tm.team_id = t.id
    WHERE tm.app_user_id = ''92b7c8c7-0161-4319-a2b5-a5ca672879c1''',
  'team_member Sittard sees only Sittard'
);

-- 7. multi-team member Heerlen+Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT results_eq(
  'SELECT id FROM team.team ORDER BY id',
  'SELECT t.id
     FROM team.team t
     JOIN team.app_user_team_membership tm ON tm.team_id = t.id
    WHERE tm.app_user_id = ''b93ba2d4-ca5c-41ce-8817-f3b9dae568ed''
   ORDER BY t.id',
  'multi-team member sees both Heerlen and Sittard'
);

--------------
--- UPDATE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  $$ UPDATE team.team
        SET name = 'Updated Name'
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  $$ SELECT id FROM team.team WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194' $$,
  'organization_admin can update teams'
);

SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ UPDATE team.team
        SET name = 'Malicious Update'
      WHERE id = 'e1a13415-84e5-4ce5-b925-45aa166cb9be'
      RETURNING id $$,
  'organization_admin cannot update teams from other organizations'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ UPDATE team.team
        SET name = 'Malicious Update'
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  'organization_member cannot update teams'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  $$ UPDATE team.team
        SET name = 'Team Heerlen'
      WHERE id = 'e59b6d1e-19e6-4bbc-ad99-ea99eb5e5049'
      RETURNING id $$,
  $$ SELECT id FROM team.team WHERE id = 'e59b6d1e-19e6-4bbc-ad99-ea99eb5e5049' $$,
  'team_admin Heerlen can update its own team'
);

SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ UPDATE team.team
        SET name = 'Malicious Update'
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  'team_admin Heerlen cannot update other teams'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT results_eq(
  $$ UPDATE team.team
        SET name = 'Team Sittard'
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  $$ SELECT id FROM team.team WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194' $$,
  'team_admin Sittard can update its own team'
);

SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ UPDATE team.team
        SET name = 'Malicious Update'
      WHERE id = 'e59b6d1e-19e6-4bbc-ad99-ea99eb5e5049'
      RETURNING id $$,
  'team_admin Sittard cannot update other teams'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ UPDATE team.team
        SET name = 'Malicious Update'
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  'team_member Heerlen cannot update teams'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ UPDATE team.team
        SET name = 'Malicious Update'
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  'team_member Sittard cannot update teams'
);

-- 7. multi-team member Heerlen+Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ UPDATE team.team
        SET name = 'Malicious Update'
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  'multi-team member cannot update teams'
);

--------------
--- DELETE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ DELETE FROM team.team
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  'organization_admin delete returns no rows'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ DELETE FROM team.team
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  'organization_member delete returns no rows'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ DELETE FROM team.team
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  'team_admin delete returns no rows'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ DELETE FROM team.team
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  'team_admin delete returns no rows'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ DELETE FROM team.team
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  'team_member delete returns no rows'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ DELETE FROM team.team
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  'team_member delete returns no rows'
);

-- 7. multi-team member Heerlen+Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ DELETE FROM team.team
      WHERE id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING id $$,
  'multi-team member delete returns no rows'
);

SELECT * FROM finish();

ROLLBACK;
