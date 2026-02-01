-- For these tests we'll be using the organization: Zuyderland Zorg
-- organization_admin: 0225f4be-0dd5-4a59-9bb8-a187c4a0390f
-- organization_member: f997d0b9-6210-44df-957a-ba363d338dd0
-- team_admin (Team Heerlen): 952a8a36-a986-4ef6-9d43-fddba534b0ed
-- team_admin (Team Sittard): ee07d2a9-050a-45d1-9db2-59f4a1f809d1
-- team_member (Team Heerlen): 6c08321a-0a5f-4045-a3cd-4888460591a1
-- team_member (Team Sittard): 92b7c8c7-0161-4319-a2b5-a5ca672879c1
-- team_member (Team Heerlen and Sittard): b93ba2d4-ca5c-41ce-8817-f3b9dae568ed

SELECT plan(30);

--------------
--- INSERT ---
--------------
BEGIN;
-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT throws_ok(
  $$ INSERT INTO organization.app_user_organization_membership (app_user_id, organization_id)
     VALUES ('0225f4be-0dd5-4a59-9bb8-a187c4a0390f', 'b1f9ee38-8733-49df-9e53-7bd280be56d0'); $$,
  'new row violates row-level security policy for table "app_user_organization_membership"',
  'organization_admin cannot insert membership'
);
ROLLBACK;

BEGIN;
-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT throws_ok(
  $$ INSERT INTO organization.app_user_organization_membership (app_user_id, organization_id)
     VALUES ('f997d0b9-6210-44df-957a-ba363d338dd0','b1f9ee38-8733-49df-9e53-7bd280be56d0'); $$,
  'new row violates row-level security policy for table "app_user_organization_membership"',
  'organization_member cannot insert membership'
);
ROLLBACK;

BEGIN;
-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT throws_ok(
  $$ INSERT INTO organization.app_user_organization_membership (app_user_id, organization_id)
     VALUES ('952a8a36-a986-4ef6-9d43-fddba534b0ed', 'b1f9ee38-8733-49df-9e53-7bd280be56d0'); $$,
  'new row violates row-level security policy for table "app_user_organization_membership"',
  'team_admin Heerlen cannot insert membership'
);
ROLLBACK;

BEGIN;
-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT throws_ok(
  $$ INSERT INTO organization.app_user_organization_membership (app_user_id, organization_id)
     VALUES ('ee07d2a9-050a-45d1-9db2-59f4a1f809d1', 'b1f9ee38-8733-49df-9e53-7bd280be56d0'); $$,
  'new row violates row-level security policy for table "app_user_organization_membership"',
  'team_admin Sittard cannot insert membership'
);
ROLLBACK;

BEGIN;
-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT throws_ok(
  $$ INSERT INTO organization.app_user_organization_membership (app_user_id, organization_id)
     VALUES ('6c08321a-0a5f-4045-a3cd-4888460591a1', 'b1f9ee38-8733-49df-9e53-7bd280be56d0'); $$,
  'new row violates row-level security policy for table "app_user_organization_membership"',
  'team_member Heerlen cannot insert membership'
);
ROLLBACK;

BEGIN;
-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT throws_ok(
  $$ INSERT INTO organization.app_user_organization_membership (app_user_id, organization_id)
     VALUES ('92b7c8c7-0161-4319-a2b5-a5ca672879c1', 'b1f9ee38-8733-49df-9e53-7bd280be56d0'); $$,
  'new row violates row-level security policy for table "app_user_organization_membership"',
  'team_member Sittard cannot insert membership'
);
ROLLBACK;

BEGIN;
-- 7. multi-team member
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT throws_ok(
  $$ INSERT INTO organization.app_user_organization_membership (app_user_id, organization_id)
     VALUES (gen_random_uuid(), 'b1f9ee38-8733-49df-9e53-7bd280be56d0'); $$,
  'new row violates row-level security policy for table "app_user_organization_membership"',
  'multi-team member cannot insert membership'
);
ROLLBACK;

--------------
--- SELECT ---
--------------

BEGIN;
-- 1. org_admin → all memberships in their org
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  'SELECT app_user_id, organization_id FROM organization.app_user_organization_membership ORDER BY app_user_id',
  'SELECT m.app_user_id, m.organization_id
     FROM organization.app_user_organization_membership m
    WHERE m.organization_id = (
      SELECT organization_id
      FROM organization.app_user_organization_membership
      WHERE app_user_id = ''0225f4be-0dd5-4a59-9bb8-a187c4a0390f''
    )
    ORDER BY m.app_user_id',
  'org_admin sees all memberships in their organization'
);

-- 2. org_member → only themselves
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT results_eq(
  'SELECT app_user_id FROM organization.app_user_organization_membership ORDER BY app_user_id',
  'SELECT m.app_user_id
     FROM organization.app_user_organization_membership m
    WHERE m.app_user_id = ''f997d0b9-6210-44df-957a-ba363d338dd0''
    ORDER BY m.app_user_id',
  'org_member sees only their own membership'
);

-- 3. team_admin Heerlen → only themselves
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  'SELECT app_user_id FROM organization.app_user_organization_membership ORDER BY app_user_id',
  'SELECT m.app_user_id
     FROM organization.app_user_organization_membership m
    WHERE m.app_user_id = ''952a8a36-a986-4ef6-9d43-fddba534b0ed''
    ORDER BY m.app_user_id',
  'team_admin Heerlen sees only their own membership'
);

-- 4. team_admin Sittard → only themselves
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT results_eq(
  'SELECT app_user_id FROM organization.app_user_organization_membership ORDER BY app_user_id',
  'SELECT m.app_user_id
     FROM organization.app_user_organization_membership m
    WHERE m.app_user_id = ''ee07d2a9-050a-45d1-9db2-59f4a1f809d1''
    ORDER BY m.app_user_id',
  'team_admin Sittard sees only their own membership'
);

-- 5. team_member Heerlen → only themselves
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT results_eq(
  'SELECT app_user_id FROM organization.app_user_organization_membership ORDER BY app_user_id',
  'SELECT m.app_user_id
     FROM organization.app_user_organization_membership m
    WHERE m.app_user_id = ''6c08321a-0a5f-4045-a3cd-4888460591a1''
    ORDER BY m.app_user_id',
  'team_member Heerlen sees only their own membership'
);

-- 6. team_member Sittard → only themselves
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT results_eq(
  'SELECT app_user_id FROM organization.app_user_organization_membership ORDER BY app_user_id',
  'SELECT m.app_user_id
     FROM organization.app_user_organization_membership m
    WHERE m.app_user_id = ''92b7c8c7-0161-4319-a2b5-a5ca672879c1''
    ORDER BY m.app_user_id',
  'team_member Sittard sees only their own membership'
);

-- 7. multi-team member Heerlen+Sittard → only themselves
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT results_eq(
  'SELECT app_user_id FROM organization.app_user_organization_membership ORDER BY app_user_id',
  'SELECT m.app_user_id
     FROM organization.app_user_organization_membership m
    WHERE m.app_user_id = ''b93ba2d4-ca5c-41ce-8817-f3b9dae568ed''
    ORDER BY m.app_user_id',
  'multi-team member sees only their own membership'
);

ROLLBACK;
--------------
--- UPDATE ---
--------------

BEGIN;
-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  $$ UPDATE organization.app_user_organization_membership
        SET role = 'organization_admin'
      WHERE app_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0'
      RETURNING app_user_id::text $$,
  $$ SELECT 'f997d0b9-6210-44df-957a-ba363d338dd0' $$,
  'organization_admin update a membership from their own organization'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ UPDATE organization.app_user_organization_membership
        SET role = 'organization_admin'
      WHERE app_user_id = '00605cea-415b-4100-a0eb-54f9221bad05'
      RETURNING app_user_id $$,
  'organization_admin cannot update a membership from another organization'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ UPDATE organization.app_user_organization_membership
        SET role = 'organization_member'
      WHERE app_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f'
      RETURNING app_user_id $$,
  'organization_admin cannot demote/promote themselves'
);
ROLLBACK;

BEGIN;
-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ UPDATE organization.app_user_organization_membership
        SET role = 'organization_admin'
      WHERE app_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0'
      RETURNING app_user_id $$,
  'organization_member update returns no rows'
);
ROLLBACK;

BEGIN;
-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ UPDATE organization.app_user_organization_membership
        SET role = 'organization_admin'
      WHERE app_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed'
      RETURNING app_user_id $$,
  'team_admin Heerlen update returns no rows'
);
ROLLBACK;

BEGIN;
-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ UPDATE organization.app_user_organization_membership
        SET role = 'organization_admin'
      WHERE app_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1'
      RETURNING app_user_id $$,
  'team_admin Sittard update returns no rows'
);
ROLLBACK;

BEGIN;
-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ UPDATE organization.app_user_organization_membership
        SET role = 'organization_admin'
      WHERE app_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1'
      RETURNING app_user_id $$,
  'team_member Heerlen update returns no rows'
);
ROLLBACK;

BEGIN;
-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ UPDATE organization.app_user_organization_membership
        SET role = 'organization_admin'
      WHERE app_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1'
      RETURNING app_user_id $$,
  'team_member Sittard update returns no rows'
);
ROLLBACK;

BEGIN;
-- 7. multi-team member
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ UPDATE organization.app_user_organization_membership
        SET role = 'organization_admin'
      WHERE app_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed'
      RETURNING app_user_id $$,
  'multi-team member update returns no rows'
);
ROLLBACK;

--------------
--- DELETE ---
--------------

BEGIN;
-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ DELETE FROM organization.app_user_organization_membership
      RETURNING app_user_id $$,
  'organization_admin cannot delete membership'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ DELETE FROM organization.app_user_organization_membership
      RETURNING app_user_id $$,
  'organization_member cannot delete membership'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ DELETE FROM organization.app_user_organization_membership
      RETURNING app_user_id $$,
  'team_admin Heerlen cannot delete membership'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ DELETE FROM organization.app_user_organization_membership
      RETURNING app_user_id $$,
  'team_admin Sittard cannot delete membership'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ DELETE FROM organization.app_user_organization_membership
      RETURNING app_user_id $$,
  'team_member Heerlen cannot delete membership'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ DELETE FROM organization.app_user_organization_membership
      RETURNING app_user_id $$,
  'team_member Sittard cannot delete membership'
);

-- 7. multi-team member
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ DELETE FROM organization.app_user_organization_membership
      RETURNING app_user_id $$,
  'multi-team member cannot delete membership'
);

SELECT * FROM finish();

ROLLBACK;
