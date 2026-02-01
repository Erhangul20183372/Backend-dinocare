-- For these tests we'll be using the organization: Zuyderland Zorg
-- organization_admin: 0225f4be-0dd5-4a59-9bb8-a187c4a0390f
-- organization_member: f997d0b9-6210-44df-957a-ba363d338dd0
-- team_admin (Team Heerlen): 952a8a36-a986-4ef6-9d43-fddba534b0ed
-- team_admin (Team Sittard): ee07d2a9-050a-45d1-9db2-59f4a1f809d1
-- team_member (Team Heerlen): 6c08321a-0a5f-4045-a3cd-4888460591a1
-- team_member (Team Sittard): 92b7c8c7-0161-4319-a2b5-a5ca672879c1
-- team_member (Team Heerlen and Sittard): b93ba2d4-ca5c-41ce-8817-f3b9dae568ed

SELECT plan(39);
BEGIN;

--------------
--- INSERT ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT throws_ok(
  $$ INSERT INTO auth.app_user (first_name, last_name, identity_id)
     VALUES ('John', 'Doe', 'e933e94e-3c63-4058-a58f-a93fe627636e'); $$,
  'new row violates row-level security policy for table "app_user"',
  'organization_admin cannot insert app_user'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT throws_ok(
  $$ INSERT INTO auth.app_user (first_name, last_name, identity_id)
     VALUES ('John', 'Doe', 'e933e94e-3c63-4058-a58f-a93fe627636e'); $$,
  'new row violates row-level security policy for table "app_user"',
  'organization_member cannot insert app_user'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT throws_ok(
  $$ INSERT INTO auth.app_user (first_name, last_name, identity_id)
     VALUES ('John', 'Doe', 'e933e94e-3c63-4058-a58f-a93fe627636e'); $$,
  'new row violates row-level security policy for table "app_user"',
  'team_admin Heerlen cannot insert app_user'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT throws_ok(
  $$ INSERT INTO auth.app_user (first_name, last_name, identity_id)
     VALUES ('John', 'Doe', 'e933e94e-3c63-4058-a58f-a93fe627636e'); $$,
  'new row violates row-level security policy for table "app_user"',
  'team_admin Sittard cannot insert app_user'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT throws_ok(
  $$ INSERT INTO auth.app_user (first_name, last_name, identity_id)
     VALUES ('John', 'Doe', 'e933e94e-3c63-4058-a58f-a93fe627636e'); $$,
  'new row violates row-level security policy for table "app_user"',
  'team_member Heerlen cannot insert app_user'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT throws_ok(
  $$ INSERT INTO auth.app_user (first_name, last_name, identity_id)
     VALUES ('John', 'Doe', 'e933e94e-3c63-4058-a58f-a93fe627636e'); $$,
  'new row violates row-level security policy for table "app_user"',
  'team_member Sittard cannot insert app_user'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT throws_ok(
  $$ INSERT INTO auth.app_user (first_name, last_name, identity_id)
     VALUES ('John', 'Doe', 'e933e94e-3c63-4058-a58f-a93fe627636e'); $$,
  'new row violates row-level security policy for table "app_user"',
  'team_member Heerlen+Sittard cannot insert app_user'
);

--------------
--- SELECT ---
--------------

-- 1. org_admin: sees all users in their organization
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  'SELECT id FROM auth.app_user ORDER BY id',
  'SELECT au.id
     FROM auth.app_user au
     JOIN organization.app_user_organization_membership om
       ON om.app_user_id = au.id
    WHERE om.organization_id = (
      SELECT organization_id
        FROM organization.app_user_organization_membership
       WHERE app_user_id = ''0225f4be-0dd5-4a59-9bb8-a187c4a0390f''
       AND role = ''organization_admin''
    )
   ORDER BY au.id',
  'org_admin sees all app_users in their organization'
);

-- 2. org_member: sees only themselves
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is((SELECT count(*) FROM auth.app_user), 1::bigint, 'org_member sees 1 app_user');
SELECT results_eq(
  'SELECT id FROM auth.app_user',
  'SELECT ''f997d0b9-6210-44df-957a-ba363d338dd0''::uuid',
  'org_member sees only their own app_user'
);

-- 3. team_admin Heerlen: sees all members of that team
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  'SELECT id FROM auth.app_user ORDER BY id',
  'SELECT au.id
     FROM auth.app_user au
     JOIN team.app_user_team_membership tm
       ON tm.app_user_id = au.id
    WHERE tm.team_id IN (
      SELECT team_id
        FROM team.app_user_team_membership
       WHERE app_user_id = ''952a8a36-a986-4ef6-9d43-fddba534b0ed''
         AND role = ''team_admin''
    )
   ORDER BY au.id',
  'team_admin Heerlen sees all members of their team'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT results_eq(
  'SELECT id FROM auth.app_user ORDER BY id',
  'SELECT au.id
     FROM auth.app_user au
     JOIN team.app_user_team_membership tm
       ON tm.app_user_id = au.id
    WHERE tm.team_id IN (
      SELECT team_id
        FROM team.app_user_team_membership
       WHERE app_user_id = ''ee07d2a9-050a-45d1-9db2-59f4a1f809d1''
         AND role = ''team_admin''
    )
   ORDER BY au.id',
  'team_admin Sittard sees all members of their team'
);

-- 5. team_member Heerlen: sees only themselves
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is((SELECT count(*) FROM auth.app_user), 1::bigint, 'team_member Heerlen sees 1 app_user');
SELECT results_eq(
  'SELECT id FROM auth.app_user',
  'SELECT ''6c08321a-0a5f-4045-a3cd-4888460591a1''::uuid',
  'team_member Heerlen sees only themselves'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is((SELECT count(*) FROM auth.app_user), 1::bigint, 'team_member Sittard sees 1 app_user');
SELECT results_eq(
  'SELECT id FROM auth.app_user',
  'SELECT ''92b7c8c7-0161-4319-a2b5-a5ca672879c1''::uuid',
  'team_member Sittard sees only themselves'
);

-- 7. team_member Heerlen+Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is((SELECT count(*) FROM auth.app_user), 1::bigint, 'multi-team member sees 1 app_user');
SELECT results_eq(
  'SELECT id FROM auth.app_user',
  'SELECT ''b93ba2d4-ca5c-41ce-8817-f3b9dae568ed''::uuid',
  'multi-team member sees only themselves'
);

--------------
--- UPDATE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
        WHERE id = 'f997d0b9-6210-44df-957a-ba363d338dd0'
      RETURNING id::text $$,
  $$ VALUES ('f997d0b9-6210-44df-957a-ba363d338dd0') $$,
  'organization_admin can edit the first name of another user in their organization'
);

SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
      WHERE id = 'b3955f39-70ae-4850-b160-c7ca4e406189'
      RETURNING id::text $$,
  'organization_admin cannot edit the first name of a user outside their organization'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT results_eq(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
        WHERE id = 'f997d0b9-6210-44df-957a-ba363d338dd0'
      RETURNING id::text $$,
  $$ VALUES ('f997d0b9-6210-44df-957a-ba363d338dd0') $$,
  'organization_member can edit their own first name'
);

SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
      WHERE id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f'
      RETURNING id::text $$,
  'organization_member cannot edit the first name of another user'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
      WHERE id = '952a8a36-a986-4ef6-9d43-fddba534b0ed'
      RETURNING id::text $$,
  $$ VALUES ('952a8a36-a986-4ef6-9d43-fddba534b0ed') $$,
  'team_admin Heerlen can edit their own first name'
);

SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
      WHERE id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1'
      RETURNING id::text $$,
  'team_admin Heerlen cannot edit the first name of another user'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT results_eq(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
      WHERE id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1'
      RETURNING id::text $$,
  $$ VALUES ('ee07d2a9-050a-45d1-9db2-59f4a1f809d1') $$,
  'team_admin Sittard can edit their own first name'
);

SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
      WHERE id = '952a8a36-a986-4ef6-9d43-fddba534b0ed'
      RETURNING id::text $$,
  'team_admin Sittard cannot edit the first name of another user'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT results_eq(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
      WHERE id = '6c08321a-0a5f-4045-a3cd-4888460591a1'
      RETURNING id::text $$,
  $$ VALUES ('6c08321a-0a5f-4045-a3cd-4888460591a1') $$,
  'team_member Heerlen can edit their own first name'
);

SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
      WHERE id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1'
      RETURNING id::text $$,
  'team_member Heerlen cannot edit the first name of another user'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT results_eq(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
      WHERE id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1'
      RETURNING id::text $$,
  $$ VALUES ('92b7c8c7-0161-4319-a2b5-a5ca672879c1') $$,
  'team_member Sittard can edit their own first name'
);

SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
      WHERE id = '952a8a36-a986-4ef6-9d43-fddba534b0ed'
      RETURNING id::text $$,
  'team_member Sittard cannot edit the first name of another user'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT results_eq(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
      WHERE id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed'
      RETURNING id::text $$,
  $$ VALUES ('b93ba2d4-ca5c-41ce-8817-f3b9dae568ed') $$,
  'team_member Heerlen+Sittard can edit their own first name'
);

SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ UPDATE auth.app_user
        SET first_name = 'NewFirstName'
      WHERE id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1'
      RETURNING id::text $$,
  'team_member Heerlen+Sittard cannot edit the first name of another user'
);

--------------
--- DELETE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ DELETE FROM auth.app_user
     WHERE id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f' 
     RETURNING id $$,
  'organization_admin cannot delete app_user'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ DELETE FROM auth.app_user
     WHERE id = 'f997d0b9-6210-44df-957a-ba363d338dd0' 
     RETURNING id $$,
  'organization_member cannot delete app_user'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ DELETE FROM auth.app_user
     WHERE id = '952a8a36-a986-4ef6-9d43-fddba534b0ed' 
     RETURNING id $$,
  'team_admin Heerlen cannot delete app_user'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ DELETE FROM auth.app_user
     WHERE id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1' 
     RETURNING id $$,
  'team_admin Sittard cannot delete app_user'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ DELETE FROM auth.app_user
     WHERE id = '6c08321a-0a5f-4045-a3cd-4888460591a1' 
     RETURNING id $$,
  'team_member Heerlen cannot delete app_user'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ DELETE FROM auth.app_user
     WHERE id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1' 
     RETURNING id $$,
  'team_member Sittard cannot delete app_user'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ DELETE FROM auth.app_user
     WHERE id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed' 
     RETURNING id $$,
  'team_member Heerlen+Sittard cannot delete app_user'
);

SELECT * FROM finish();

ROLLBACK;
