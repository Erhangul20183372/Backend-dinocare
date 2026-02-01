-- For these tests we'll be using the organization: Zuyderland Zorg
-- organization_admin: 0225f4be-0dd5-4a59-9bb8-a187c4a0390f
-- organization_member: f997d0b9-6210-44df-957a-ba363d338dd0
-- team_admin (Team Heerlen): 952a8a36-a986-4ef6-9d43-fddba534b0ed
-- team_admin (Team Sittard): ee07d2a9-050a-45d1-9db2-59f4a1f809d1
-- team_member (Team Heerlen): 6c08321a-0a5f-4045-a3cd-4888460591a1
-- team_member (Team Sittard): 92b7c8c7-0161-4319-a2b5-a5ca672879c1
-- team_member (Team Heerlen and Sittard): b93ba2d4-ca5c-41ce-8817-f3b9dae568ed

SELECT plan(36);

--------------
--- INSERT ---
--------------
BEGIN;
-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT lives_ok(
  $$ INSERT INTO team.app_user_team_membership (app_user_id, team_id, invited_by, role)
      VALUES ('6c08321a-0a5f-4045-a3cd-4888460591a1', 'e39c3f9c-e633-4ad9-96dd-c48e8782f194', '0225f4be-0dd5-4a59-9bb8-a187c4a0390f', 'team_member') $$,
  'organization_admin can insert app_user_team_membership'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT throws_ok(
  $$ INSERT INTO team.app_user_team_membership (app_user_id, team_id, invited_by, role)
      VALUES ('00605cea-415b-4100-a0eb-54f9221bad05', 'e39c3f9c-e633-4ad9-96dd-c48e8782f194', '0225f4be-0dd5-4a59-9bb8-a187c4a0390f', 'team_member') $$,
  'new row violates row-level security policy for table "app_user_team_membership"',
  'organization_admin cannot insert app_user from outside organization'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT throws_ok(
  $$ INSERT INTO team.app_user_team_membership (app_user_id, team_id, invited_by, role)
      VALUES ('204ed978-f7a3-476c-a3d4-027732f38e3a', '1e777869-b91a-40be-a1bb-4c19c871230a', '0225f4be-0dd5-4a59-9bb8-a187c4a0390f', 'team_member') $$,
  'new row violates row-level security policy for table "app_user_team_membership"',
  'organization_admin cannot insert into team from another organization'
);
ROLLBACK;

BEGIN;
-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT throws_ok(
  $$ INSERT INTO team.app_user_team_membership (app_user_id, team_id)
      VALUES ('f997d0b9-6210-44df-957a-ba363d338dd0', 'e39c3f9c-e633-4ad9-96dd-c48e8782f194') $$,
  'new row violates row-level security policy for table "app_user_team_membership"',
  'organization_member cannot insert app_user_team_membership'
);
ROLLBACK;

BEGIN;
-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT throws_ok(
  $$ INSERT INTO team.app_user_team_membership (app_user_id, team_id)
      VALUES ('f997d0b9-6210-44df-957a-ba363d338dd0', 'e39c3f9c-e633-4ad9-96dd-c48e8782f194') $$,
  'new row violates row-level security policy for table "app_user_team_membership"',
  'team_admin Heerlen cannot insert app_user_team_membership for other users'
);
ROLLBACK;

BEGIN;
-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT throws_ok(
  $$ INSERT INTO team.app_user_team_membership (app_user_id, team_id)
      VALUES ('f997d0b9-6210-44df-957a-ba363d338dd0', 'e39c3f9c-e633-4ad9-96dd-c48e8782f194') $$,
  'new row violates row-level security policy for table "app_user_team_membership"',
  'team_admin Sittard cannot insert app_user_team_membership for other users'
);
ROLLBACK;

BEGIN;
-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT throws_ok(
  $$ INSERT INTO team.app_user_team_membership (app_user_id, team_id)
      VALUES ('6c08321a-0a5f-4045-a3cd-4888460591a1', 'e39c3f9c-e633-4ad9-96dd-c48e8782f194') $$,
  'new row violates row-level security policy for table "app_user_team_membership"',
  'team_member Heerlen cannot insert app_user_team_membership even for themselves'
);
ROLLBACK;

BEGIN;
-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT throws_ok(
  $$ INSERT INTO team.app_user_team_membership (app_user_id, team_id)
      VALUES ('92b7c8c7-0161-4319-a2b5-a5ca672879c1', 'e39c3f9c-e633-4ad9-96dd-c48e8782f194') $$,
  'new row violates row-level security policy for table "app_user_team_membership"',
  'team_member Sittard cannot insert app_user_team_membership even for themselves'
);
ROLLBACK;

BEGIN;
-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT throws_ok(
  $$ INSERT INTO team.app_user_team_membership (app_user_id, team_id)
      VALUES ('b93ba2d4-ca5c-41ce-8817-f3b9dae568ed', 'e39c3f9c-e633-4ad9-96dd-c48e8782f194') $$,
  'new row violates row-level security policy for table "app_user_team_membership"',
  'team_member Heerlen + Sittard cannot insert app_user_team_membership even for themselves'
);
ROLLBACK;

--------------
--- SELECT ---
--------------

BEGIN;
-- 1. org_admin → all memberships in their org
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  'SELECT app_user_id, team_id FROM team.app_user_team_membership ORDER BY app_user_id, team_id',
  'SELECT m.app_user_id, m.team_id
     FROM team.app_user_team_membership m
     JOIN team.team t ON m.team_id = t.id
    WHERE t.organization_id = (
      SELECT organization_id
      FROM organization.app_user_organization_membership
      WHERE app_user_id = ''0225f4be-0dd5-4a59-9bb8-a187c4a0390f''
      AND role = ''organization_admin''
    )
    ORDER BY m.app_user_id, m.team_id',
  'org_admin sees all team memberships in their organization'
);

-- 2. org_member → nothing
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is((SELECT count(*) FROM team.app_user_team_membership), 0::bigint, 'org_member sees no team memberships');

-- 3. team_admin Heerlen → all memberships of Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  'SELECT app_user_id, team_id FROM team.app_user_team_membership ORDER BY app_user_id, team_id',
  'SELECT m.app_user_id, m.team_id
     FROM team.app_user_team_membership m
    WHERE m.team_id IN (
      SELECT team_id
      FROM team.app_user_team_membership
      WHERE app_user_id = ''952a8a36-a986-4ef6-9d43-fddba534b0ed''
    )
    ORDER BY m.app_user_id, m.team_id',
  'team_admin Heerlen sees all memberships in their team(s)'
);

-- 4. team_admin Sittard → all memberships of Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT results_eq(
  'SELECT app_user_id, team_id FROM team.app_user_team_membership ORDER BY app_user_id, team_id',
  'SELECT m.app_user_id, m.team_id
     FROM team.app_user_team_membership m
    WHERE m.team_id IN (
      SELECT team_id
      FROM team.app_user_team_membership
      WHERE app_user_id = ''ee07d2a9-050a-45d1-9db2-59f4a1f809d1''
    )
    ORDER BY m.app_user_id, m.team_id',
  'team_admin Sittard sees all memberships in their team(s)'
);

-- 5. team_member Heerlen → only themselves
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT results_eq(
  'SELECT app_user_id, team_id FROM team.app_user_team_membership ORDER BY app_user_id, team_id',
  'SELECT m.app_user_id, m.team_id
     FROM team.app_user_team_membership m
    WHERE m.app_user_id = ''6c08321a-0a5f-4045-a3cd-4888460591a1''
    ORDER BY m.app_user_id, m.team_id',
  'team_member Heerlen sees only their own membership'
);

-- 6. team_member Sittard → only themselves
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT results_eq(
  'SELECT app_user_id, team_id FROM team.app_user_team_membership ORDER BY app_user_id, team_id',
  'SELECT m.app_user_id, m.team_id
     FROM team.app_user_team_membership m
    WHERE m.app_user_id = ''92b7c8c7-0161-4319-a2b5-a5ca672879c1''
    ORDER BY m.app_user_id, m.team_id',
  'team_member Sittard sees only their own membership'
);

-- 7. multi-team member Heerlen+Sittard → both memberships, but only themselves
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT results_eq(
  'SELECT app_user_id, team_id FROM team.app_user_team_membership ORDER BY app_user_id, team_id',
  'SELECT m.app_user_id, m.team_id
     FROM team.app_user_team_membership m
    WHERE m.app_user_id = ''b93ba2d4-ca5c-41ce-8817-f3b9dae568ed''
    ORDER BY m.app_user_id, m.team_id',
  'multi-team member sees only their own memberships'
);
ROLLBACK;

--------------
--- UPDATE ---
--------------

BEGIN;
-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  $$ UPDATE team.app_user_team_membership
        SET role = 'team_admin'
        WHERE app_user_id = '235d0a38-5053-4cfe-abb6-cc829674dba7'
        AND team_id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING app_user_id::text $$,
  $$ VALUES ('235d0a38-5053-4cfe-abb6-cc829674dba7') $$,
  'organization_admin can edit a record from their organization'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ UPDATE team.app_user_team_membership
        SET role = 'team_admin'
      WHERE app_user_id = 'b3955f39-70ae-4850-b160-c7ca4e406189'
      RETURNING app_user_id::text $$,
  'organization_admin cannot edit a record from outside their organization'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ UPDATE team.app_user_team_membership
        SET role = 'team_member'
      WHERE app_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f'
      RETURNING app_user_id::text $$,
  'organization_admin cannot demote/promote themselves'
);
ROLLBACK;

BEGIN;
-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ UPDATE team.app_user_team_membership
        SET role = 'team_admin'
      WHERE app_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed'
      RETURNING app_user_id::text $$,
  'organization_member cannot edit a record from their organization'
);
ROLLBACK;

BEGIN;
-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  $$ UPDATE team.app_user_team_membership
        SET role = 'team_admin'
      WHERE app_user_id = '235d0a38-5053-4cfe-abb6-cc829674dba7'
      AND team_id = 'e59b6d1e-19e6-4bbc-ad99-ea99eb5e5049'
      RETURNING app_user_id::text $$,
  $$ VALUES ('235d0a38-5053-4cfe-abb6-cc829674dba7') $$,
  'team_admin Heerlen can edit their own record'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ UPDATE team.app_user_team_membership
        SET role = 'team_admin'
      WHERE app_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed'
      AND team_id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING app_user_id::text $$,
  'team_admin Heerlen cannot edit a record from another team'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ UPDATE team.app_user_team_membership
        SET role = 'team_member'
      WHERE app_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed'
      RETURNING app_user_id::text $$,
  'team_admin Heerlen cannot demote/promote themselves'
);
ROLLBACK;

BEGIN;
-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT results_eq(
  $$ UPDATE team.app_user_team_membership
        SET role = 'team_admin'
      WHERE app_user_id = '235d0a38-5053-4cfe-abb6-cc829674dba7'
      AND team_id = 'e39c3f9c-e633-4ad9-96dd-c48e8782f194'
      RETURNING app_user_id::text $$,
  $$ VALUES ('235d0a38-5053-4cfe-abb6-cc829674dba7') $$,
  'team_admin Sittard can edit their own record'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ UPDATE team.app_user_team_membership
        SET role = 'team_admin'
      WHERE app_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1'
      AND team_id = 'e59b6d1e-19e6-4bbc-ad99-ea99eb5e5049'
      RETURNING app_user_id::text $$,
  'team_admin Sittard cannot edit a record from another team'
);
ROLLBACK;

BEGIN;
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ UPDATE team.app_user_team_membership
        SET role = 'team_member'
      WHERE app_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1'
      RETURNING app_user_id::text $$,
  'team_admin Sittard cannot demote/promote themselves'
);
ROLLBACK;

BEGIN;
-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ UPDATE team.app_user_team_membership
        SET role = 'team_admin'
      WHERE app_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1'
      RETURNING app_user_id::text $$,
  'team_member Heerlen cannot edit'
);
ROLLBACK;

BEGIN;
-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ UPDATE team.app_user_team_membership
        SET role = 'team_admin'
      WHERE app_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1'
      RETURNING app_user_id::text $$,
  'team_member Sittard cannot edit'
);
ROLLBACK;

BEGIN;
-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ UPDATE team.app_user_team_membership
        SET role = 'team_admin'
      WHERE app_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed'
      RETURNING app_user_id::text $$,
  'team_member Heerlen + Sittard cannot edit'
);
ROLLBACK;

--------------
--- DELETE ---
--------------

BEGIN;
-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ DELETE FROM team.app_user_team_membership
      WHERE app_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f'
      RETURNING app_user_id $$,
  'organization_admin delete returns no rows'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ DELETE FROM team.app_user_team_membership
      WHERE app_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0'
      RETURNING app_user_id $$,
  'organization_member delete returns no rows'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ DELETE FROM team.app_user_team_membership
      WHERE app_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed'
      RETURNING app_user_id $$,
  'team_admin Heerlen delete returns no rows'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ DELETE FROM team.app_user_team_membership
      WHERE app_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1'
      RETURNING app_user_id $$,
  'team_admin Sittard delete returns no rows'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ DELETE FROM team.app_user_team_membership
      WHERE app_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1'
      RETURNING app_user_id $$,
  'team_member Heerlen delete returns no rows'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ DELETE FROM team.app_user_team_membership
      WHERE app_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1'
      RETURNING app_user_id $$,
  'team_member Sittard delete returns no rows'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ DELETE FROM team.app_user_team_membership
      WHERE app_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed'
      RETURNING app_user_id $$,
  'team_member Heerlen + Sittard delete returns no rows'
);

SELECT * FROM finish();

ROLLBACK;
