-- For these tests we'll be using the organization: Zuyderland Zorg
-- organization_admin: 0225f4be-0dd5-4a59-9bb8-a187c4a0390f
-- organization_member: f997d0b9-6210-44df-957a-ba363d338dd0
-- team_admin (Team Heerlen): 952a8a36-a986-4ef6-9d43-fddba534b0ed
-- team_admin (Team Sittard): ee07d2a9-050a-45d1-9db2-59f4a1f809d1
-- team_member (Team Heerlen): 6c08321a-0a5f-4045-a3cd-4888460591a1
-- team_member (Team Sittard): 92b7c8c7-0161-4319-a2b5-a5ca672879c1
-- team_member (Team Heerlen and Sittard): b93ba2d4-ca5c-41ce-8817-f3b9dae568ed

SELECT plan(40);

BEGIN;

--------------
--- INSERT ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT lives_ok(
  $$ INSERT INTO client.client (id, team_id, gender, first_name, last_name)
     VALUES (gen_random_uuid(), 'e59b6d1e-19e6-4bbc-ad99-ea99eb5e5049', 'male', 'John', 'Doe'); $$,
  'organization_admin can insert clients for a team in their organization'
);

SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT throws_ok(
  $$ INSERT INTO client.client (id, team_id, gender, first_name, last_name)
     VALUES (gen_random_uuid(), 'e1a13415-84e5-4ce5-b925-45aa166cb9be', 'male', 'John', 'Doe'); $$,
  'new row violates row-level security policy for table "client"',
  'organization_admin cannot insert clients for a team outside their organization'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT throws_ok(
  $$ INSERT INTO client.client (id, team_id, gender, first_name, last_name)
     VALUES (gen_random_uuid(), 'e59b6d1e-19e6-4bbc-ad99-ea99eb5e5049', 'male', 'John', 'Doe'); $$,
  'new row violates row-level security policy for table "client"',
  'organization_member cannot insert clients for a team in their organization'
);


-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT lives_ok(
  $$ INSERT INTO client.client (id, team_id, gender, first_name, last_name)
     VALUES (gen_random_uuid(), 'e59b6d1e-19e6-4bbc-ad99-ea99eb5e5049', 'male', 'John', 'Doe'); $$,
  'team_admin Heerlen can insert clients for their team'
);

SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT throws_ok(
  $$ INSERT INTO client.client (id, team_id, gender, first_name, last_name)
     VALUES (gen_random_uuid(), 'e1a13415-84e5-4ce5-b925-45aa166cb9be', 'male', 'John', 'Doe'); $$,
  'new row violates row-level security policy for table "client"',
  'team_admin Heerlen cannot insert clients for a team outside their membership'
);


-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT lives_ok(
  $$ INSERT INTO client.client (id, team_id, gender, first_name, last_name)
     VALUES (gen_random_uuid(), 'e39c3f9c-e633-4ad9-96dd-c48e8782f194', 'male', 'John', 'Doe'); $$,
  'team_admin Sittard can insert clients for their team'
);

SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT throws_ok(
  $$ INSERT INTO client.client (id, team_id, gender, first_name, last_name)
     VALUES (gen_random_uuid(), 'e1a13415-84e5-4ce5-b925-45aa166cb9be', 'male', 'John', 'Doe'); $$,
  'new row violates row-level security policy for table "client"',
  'team_admin Sittard cannot insert clients for a team outside their membership'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT lives_ok(
  $$ INSERT INTO client.client (id, team_id, gender, first_name, last_name)
     VALUES (gen_random_uuid(), 'e59b6d1e-19e6-4bbc-ad99-ea99eb5e5049', 'male', 'John', 'Doe'); $$,
  'team_member Heerlen can insert clients for their team'
);

SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT throws_ok(
  $$ INSERT INTO client.client (id, team_id, gender, first_name, last_name)
     VALUES (gen_random_uuid(), 'e39c3f9c-e633-4ad9-96dd-c48e8782f194', 'male', 'John', 'Doe'); $$,
  'new row violates row-level security policy for table "client"',
  'team_member Heerlen cannot insert clients for a team outside their membership'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT lives_ok(
  $$ INSERT INTO client.client (id, team_id, gender, first_name, last_name)
     VALUES (gen_random_uuid(), 'e39c3f9c-e633-4ad9-96dd-c48e8782f194', 'male', 'John', 'Doe'); $$,
  'team_member Sittard can insert clients for their team'
);

SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT throws_ok(
  $$ INSERT INTO client.client (id, team_id, gender, first_name, last_name)
     VALUES (gen_random_uuid(), 'e59b6d1e-19e6-4bbc-ad99-ea99eb5e5049', 'male', 'John', 'Doe'); $$,
  'new row violates row-level security policy for table "client"',
  'team_member Sittard cannot insert clients for a team outside their membership'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT lives_ok(
  $$ INSERT INTO client.client (id, team_id, gender, first_name, last_name)
     VALUES (gen_random_uuid(), 'e59b6d1e-19e6-4bbc-ad99-ea99eb5e5049', 'male', 'John', 'Doe'); $$,
  'multi-team member can insert clients for Team Heerlen'
);

SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT throws_ok(
  $$ INSERT INTO client.client (id, team_id, gender, first_name, last_name)
     VALUES (gen_random_uuid(), 'e1a13415-84e5-4ce5-b925-45aa166cb9be', 'male', 'John', 'Doe'); $$,
  'new row violates row-level security policy for table "client"',
  'multi-team member cannot insert clients for a team outside their membership'
);

--------------
--- SELECT ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  'SELECT id FROM client.client ORDER BY id',
  'SELECT c.id
     FROM client.client c
     JOIN team.team t ON c.team_id = t.id
    WHERE t.organization_id = (
      SELECT organization_id
      FROM organization.app_user_organization_membership
      WHERE app_user_id = ''0225f4be-0dd5-4a59-9bb8-a187c4a0390f''
    )
   ORDER BY c.id',
  'organization_admin sees all clients in their organization'
);

-- 2. organization_member 
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is((SELECT count(*) FROM client.client), 0::bigint, 'organization_member sees no clients');

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  'SELECT id FROM client.client ORDER BY id',
  'SELECT c.id
     FROM client.client c
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''952a8a36-a986-4ef6-9d43-fddba534b0ed''
   ORDER BY c.id',
  'team_admin Heerlen sees all clients in their teams'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT results_eq(
  'SELECT id FROM client.client ORDER BY id',
  'SELECT c.id
     FROM client.client c
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''ee07d2a9-050a-45d1-9db2-59f4a1f809d1''
   ORDER BY c.id',
  'team_admin Sittard sees all clients in their teams'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT results_eq(
  'SELECT id FROM client.client ORDER BY id',
  'SELECT c.id
     FROM client.client c
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''6c08321a-0a5f-4045-a3cd-4888460591a1''
   ORDER BY c.id',
  'team_member Heerlen sees all clients in their teams'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT results_eq(
  'SELECT id FROM client.client ORDER BY id',
  'SELECT c.id
     FROM client.client c
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''92b7c8c7-0161-4319-a2b5-a5ca672879c1''
   ORDER BY c.id',
  'team_member Sittard sees all clients in their teams'
);

-- 7. multi-team member Heerlen+Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT results_eq(
  'SELECT id FROM client.client ORDER BY id',
  'SELECT c.id
     FROM client.client c
     JOIN team.app_user_team_membership tm ON tm.team_id = c.team_id
    WHERE tm.app_user_id = ''b93ba2d4-ca5c-41ce-8817-f3b9dae568ed''
   ORDER BY c.id',
  'multi-team member sees all clients in both teams'
);

--------------
--- UPDATE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  $$ UPDATE client.client 
       SET first_name = 'Jane' 
     WHERE id = 'a3871686-bc06-4cb6-996d-b3453e5df0a5' 
     RETURNING first_name $$,
  $$ SELECT 'Jane' $$,
  'organization_admin can update a client in their organization'
);

SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ UPDATE client.client 
       SET first_name = 'Jane' 
     WHERE id = '1f08397e-6a06-495d-9aca-924b87113435' 
     RETURNING id $$,
  'organization_admin cannot update a client outside their organization'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ UPDATE client.client 
       SET first_name = 'Jane' 
     WHERE id = 'a3871686-bc06-4cb6-996d-b3453e5df0a5' 
     RETURNING id $$,
  'organization_member cannot update clients'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  $$ UPDATE client.client 
       SET first_name = 'Jane' 
     WHERE id = 'a3871686-bc06-4cb6-996d-b3453e5df0a5' 
     RETURNING first_name $$,
  $$ SELECT 'Jane' $$,
  'team_admin Heerlen can update a client in their team'
);

SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ UPDATE client.client 
       SET first_name = 'Jane' 
     WHERE id = '01a4b588-79a4-4f8a-a30a-390fce380e83' 
     RETURNING id $$,
  'team_admin Heerlen cannot update a client outside their membership'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT results_eq(
  $$ UPDATE client.client 
       SET first_name = 'Jane' 
     WHERE id = '8d60e42d-016a-4b08-9610-d6b58b092c1b' 
     RETURNING first_name $$,
  $$ SELECT 'Jane' $$,
  'team_admin Sittard can update a client in their team'
);

SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ UPDATE client.client 
       SET first_name = 'Jane' 
     WHERE id = '01a4b588-79a4-4f8a-a30a-390fce380e83' 
     RETURNING id $$,
  'team_admin Sittard cannot update a client outside their team'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT results_eq(
  $$ UPDATE client.client 
       SET first_name = 'Jane' 
     WHERE id = 'a3871686-bc06-4cb6-996d-b3453e5df0a5' 
     RETURNING first_name $$,
  $$ SELECT 'Jane' $$,
  'team_member Heerlen can update a client in their team'
);

SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ UPDATE client.client 
       SET first_name = 'Jane' 
     WHERE id = '01a4b588-79a4-4f8a-a30a-390fce380e83' 
     RETURNING id $$,
  'team_member Heerlen cannot update a client outside their team'
);


-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT results_eq(
  $$ UPDATE client.client 
       SET first_name = 'Jane' 
     WHERE id = '8d60e42d-016a-4b08-9610-d6b58b092c1b' 
     RETURNING first_name $$,
  $$ SELECT 'Jane' $$,
  'team_member Sittard can update a client in their team'
);

SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ UPDATE client.client 
       SET first_name = 'Jane' 
     WHERE id = '01a4b588-79a4-4f8a-a30a-390fce380e83' 
     RETURNING id $$,
  'team_member Sittard cannot update a client outside their team'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT results_eq(
  $$ UPDATE client.client 
       SET first_name = 'Jane' 
     WHERE id = 'a3871686-bc06-4cb6-996d-b3453e5df0a5' 
     RETURNING first_name $$,
  $$ SELECT 'Jane' $$,
  'team_member Heerlen + Sittard can update a client in their organization'
);

SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ UPDATE client.client 
       SET first_name = 'Jane' 
     WHERE id = '1f08397e-6a06-495d-9aca-924b87113435' 
     RETURNING id $$,
  'team_member Heerlen + Sittard cannot update a client outside their organization'
);

--------------
--- DELETE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ DELETE FROM client.client 
      WHERE id = '944fc0ef-2c47-4081-80f1-13828e9c1573' 
      RETURNING id $$,
  'organization_admin cannot delete a client in their organization'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ DELETE FROM client.client 
      WHERE id = '944fc0ef-2c47-4081-80f1-13828e9c1573' 
      RETURNING id $$,
  'organization_member cannot delete clients'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ DELETE FROM client.client 
      WHERE id = '944fc0ef-2c47-4081-80f1-13828e9c1573' 
      RETURNING id $$,
  'team_admin Heerlen cannot delete a client in their team'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ DELETE FROM client.client 
      WHERE id = '944fc0ef-2c47-4081-80f1-13828e9c1573' 
      RETURNING id $$,
  'team_admin Sittard cannot delete a client in their team'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ DELETE FROM client.client 
      WHERE id = '944fc0ef-2c47-4081-80f1-13828e9c1573' 
      RETURNING id $$,
  'team_member Heerlen cannot delete clients'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ DELETE FROM client.client 
      WHERE id = '944fc0ef-2c47-4081-80f1-13828e9c1573' 
      RETURNING id $$,
  'team_member Sittard cannot delete clients'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ DELETE FROM client.client 
      WHERE id = '944fc0ef-2c47-4081-80f1-13828e9c1573' 
      RETURNING id $$,
  'team_member Heerlen + Sittard cannot delete clients'
);

SELECT * FROM finish();

ROLLBACK;
