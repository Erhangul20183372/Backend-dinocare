-- For these tests we'll be using the organization: Zuyderland Zorg
-- organization_admin: 0225f4be-0dd5-4a59-9bb8-a187c4a0390f
-- organization_member: f997d0b9-6210-44df-957a-ba363d338dd0
-- team_admin (Team Heerlen): 952a8a36-a986-4ef6-9d43-fddba534b0ed
-- team_admin (Team Sittard): ee07d2a9-050a-45d1-9db2-59f4a1f809d1
-- team_member (Team Heerlen): 6c08321a-0a5f-4045-a3cd-4888460591a1
-- team_member (Team Sittard): 92b7c8c7-0161-4319-a2b5-a5ca672879c1
-- team_member (Team Heerlen and Sittard): b93ba2d4-ca5c-41ce-8817-f3b9dae568ed

SELECT plan(36);

BEGIN;

--------------
--- INSERT ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT throws_ok(
  $$ INSERT INTO organization.organization (id, name, domain)
     VALUES (gen_random_uuid(), 'HackOrg1', 'hack1.org'); $$,
  'new row violates row-level security policy for table "organization"',
  'organization_admin cannot insert organization'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT throws_ok(
  $$ INSERT INTO organization.organization (id, name, domain)
     VALUES (gen_random_uuid(), 'HackOrg2', 'hack2.org'); $$,
  'new row violates row-level security policy for table "organization"',
  'organization_member cannot insert organization'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT throws_ok(
  $$ INSERT INTO organization.organization (id, name, domain)
     VALUES (gen_random_uuid(), 'HackOrg3', 'hack3.org'); $$,
  'new row violates row-level security policy for table "organization"',
  'team_admin (Heerlen) cannot insert organization'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT throws_ok(
  $$ INSERT INTO organization.organization (id, name, domain)
     VALUES (gen_random_uuid(), 'HackOrg4', 'hack4.org'); $$,
  'new row violates row-level security policy for table "organization"',
  'team_admin (Sittard) cannot insert organization'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT throws_ok(
  $$ INSERT INTO organization.organization (id, name, domain)
     VALUES (gen_random_uuid(), 'HackOrg5', 'hack5.org'); $$,
  'new row violates row-level security policy for table "organization"',
  'team_member (Heerlen) cannot insert organization'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT throws_ok(
  $$ INSERT INTO organization.organization (id, name, domain)
     VALUES (gen_random_uuid(), 'HackOrg6', 'hack6.org'); $$,
  'new row violates row-level security policy for table "organization"',
  'team_member (Sittard) cannot insert organization'
);

-- 7. team_member Heerlen+Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT throws_ok(
  $$ INSERT INTO organization.organization (id, name, domain)
     VALUES (gen_random_uuid(), 'HackOrg7', 'hack7.org'); $$,
  'new row violates row-level security policy for table "organization"',
  'team_member (Heerlen + Sittard) cannot insert organization'
);

--------------
--- SELECT ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is((SELECT count(*) FROM organization.organization), 1::bigint, 'organization_admin sees exactly 1 organization');
SELECT results_eq(
  'SELECT id FROM organization.organization',
  'SELECT organization_id
     FROM organization.app_user_organization_membership
    WHERE app_user_id = ''0225f4be-0dd5-4a59-9bb8-a187c4a0390f''',
  'organization_admin sees their own organization'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is((SELECT count(*) FROM organization.organization), 1::bigint, 'organization_member sees exactly 1 organization');
SELECT results_eq(
  'SELECT id FROM organization.organization',
  'SELECT organization_id
     FROM organization.app_user_organization_membership
    WHERE app_user_id = ''f997d0b9-6210-44df-957a-ba363d338dd0''',
  'organization_member sees their own organization'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is((SELECT count(*) FROM organization.organization), 1::bigint, 'team_admin Heerlen sees exactly 1 organization');
SELECT results_eq(
  'SELECT id FROM organization.organization',
  'SELECT organization_id
     FROM organization.app_user_organization_membership
    WHERE app_user_id = ''952a8a36-a986-4ef6-9d43-fddba534b0ed''',
  'team_admin Heerlen sees their own organization'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is((SELECT count(*) FROM organization.organization), 1::bigint, 'team_admin Sittard sees exactly 1 organization');
SELECT results_eq(
  'SELECT id FROM organization.organization',
  'SELECT organization_id
     FROM organization.app_user_organization_membership
    WHERE app_user_id = ''ee07d2a9-050a-45d1-9db2-59f4a1f809d1''',
  'team_admin Sittard sees their own organization'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is((SELECT count(*) FROM organization.organization), 1::bigint, 'team_member Heerlen sees exactly 1 organization');
SELECT results_eq(
  'SELECT id FROM organization.organization',
  'SELECT organization_id
     FROM organization.app_user_organization_membership
    WHERE app_user_id = ''6c08321a-0a5f-4045-a3cd-4888460591a1''',
  'team_member Heerlen sees their own organization'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is((SELECT count(*) FROM organization.organization), 1::bigint, 'team_member Sittard sees exactly 1 organization');
SELECT results_eq(
  'SELECT id FROM organization.organization',
  'SELECT organization_id
     FROM organization.app_user_organization_membership
    WHERE app_user_id = ''92b7c8c7-0161-4319-a2b5-a5ca672879c1''',
  'team_member Sittard sees their own organization'
);

-- 7. team_member Heerlen+Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is((SELECT count(*) FROM organization.organization), 1::bigint, 'multi-team member sees exactly 1 organization');
SELECT results_eq(
  'SELECT id FROM organization.organization',
  'SELECT organization_id
     FROM organization.app_user_organization_membership
    WHERE app_user_id = ''b93ba2d4-ca5c-41ce-8817-f3b9dae568ed''',
  'multi-team member sees their own organization'
);

--------------
--- UPDATE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  $$ UPDATE organization.organization
        SET name = 'Updated Org by Admin'
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  $$ VALUES ('zuyderland.nl') $$,
  'organization_admin update returned the expected row'
);

SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ UPDATE organization.organization
        SET name = 'Malicious Update'
      WHERE domain = 'aafje.nl'
      RETURNING domain::text $$,
  'organization_admin cannot update other organizations'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ UPDATE organization.organization
        SET name = 'Updated Org by Member'
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  'organization_member update returns no rows'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ UPDATE organization.organization
        SET name = 'Updated Org by Heerlen Admin'
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  'team_admin Heerlen update returns no rows'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ UPDATE organization.organization
        SET name = 'Updated Org by Sittard Admin'
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  'team_admin Sittard update returns no rows'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ UPDATE organization.organization
        SET name = 'Updated Org by Heerlen Member'
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  'team_member Heerlen update returns no rows'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ UPDATE organization.organization
        SET name = 'Updated Org by Sittard Member'
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  'team_member Sittard update returns no rows'
);

-- 7. team_member Heerlen+Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ UPDATE organization.organization
        SET name = 'Updated Org by Multi-Team Member'
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  'multi-team member update returns no rows'
);

--------------
--- DELETE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ DELETE FROM organization.organization
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  'organization_admin delete returns no rows'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ DELETE FROM organization.organization
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  'organization_member delete returns no rows'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ DELETE FROM organization.organization
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  'team_admin Heerlen delete returns no rows'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ DELETE FROM organization.organization
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  'team_admin Sittard delete returns no rows'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ DELETE FROM organization.organization
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  'team_member Heerlen delete returns no rows'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ DELETE FROM organization.organization
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  'team_member Sittard delete returns no rows'
);

-- 7. team_member Heerlen+Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ DELETE FROM organization.organization
      WHERE domain = 'zuyderland.nl'
      RETURNING domain::text $$,
  'multi-team member delete returns no rows'
);

SELECT * FROM finish();

ROLLBACK;
