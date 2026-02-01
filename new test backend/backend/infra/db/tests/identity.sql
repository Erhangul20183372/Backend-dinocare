-- For these tests we'll be using the organization: Zuyderland Zorg
-- organization_admin: 0225f4be-0dd5-4a59-9bb8-a187c4a0390f
-- organization_member: f997d0b9-6210-44df-957a-ba363d338dd0
-- team_admin (Team Heerlen): 952a8a36-a986-4ef6-9d43-fddba534b0ed
-- team_admin (Team Sittard): ee07d2a9-050a-45d1-9db2-59f4a1f809d1
-- team_member (Team Heerlen): 6c08321a-0a5f-4045-a3cd-4888460591a1
-- team_member (Team Sittard): 92b7c8c7-0161-4319-a2b5-a5ca672879c1
-- team_member (Team Heerlen and Sittard): b93ba2d4-ca5c-41ce-8817-f3b9dae568ed

SELECT plan(42);

BEGIN;

--------------
--- INSERT ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT throws_ok(
  $$ INSERT INTO auth.identity (email_address, password_hash)
     VALUES ('org_admin@example.com', 'hashed_password'); $$,
  'new row violates row-level security policy for table "identity"',
  'organization_admin cannot insert identity'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT throws_ok(
  $$ INSERT INTO auth.identity (email_address, password_hash)
     VALUES ('org_member@example.com', 'hashed_password'); $$,
  'new row violates row-level security policy for table "identity"',
  'organization_member cannot insert identity'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT throws_ok(
  $$ INSERT INTO auth.identity (email_address, password_hash)
     VALUES ('team_admin_he@example.com', 'hashed_password'); $$,
  'new row violates row-level security policy for table "identity"',
  'team_admin Heerlen cannot insert identity'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT throws_ok(
  $$ INSERT INTO auth.identity (email_address, password_hash)
     VALUES ('team_admin_si@example.com', 'hashed_password'); $$,
  'new row violates row-level security policy for table "identity"',
  'team_admin Sittard cannot insert identity'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT throws_ok(
  $$ INSERT INTO auth.identity (email_address, password_hash)
     VALUES ('team_member_he@example.com', 'hashed_password'); $$,
  'new row violates row-level security policy for table "identity"',
  'team_member Heerlen cannot insert identity'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT throws_ok(
  $$ INSERT INTO auth.identity (email_address, password_hash)
     VALUES ('team_member_si@example.com', 'hashed_password'); $$,
  'new row violates row-level security policy for table "identity"',
  'team_member Sittard cannot insert identity'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT throws_ok(
  $$ INSERT INTO auth.identity (email_address, password_hash)
     VALUES ('team_member_he@example.com', 'hashed_password'); $$,
  'new row violates row-level security policy for table "identity"',
  'team_member Heerlen + Sittard cannot insert identity'
);

--------------
--- SELECT ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is((SELECT count(*) FROM auth.identity), 1::bigint, 'organization_admin sees exactly 1 identity');
SELECT results_eq(
  'SELECT id FROM auth.identity',
  'SELECT identity_id FROM auth.app_user WHERE id = ''0225f4be-0dd5-4a59-9bb8-a187c4a0390f''',
  'organization_admin sees their own identity'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is((SELECT count(*) FROM auth.identity), 1::bigint, 'organization_member sees exactly 1 identity');
SELECT results_eq(
  'SELECT id FROM auth.identity',
  'SELECT identity_id FROM auth.app_user WHERE id = ''f997d0b9-6210-44df-957a-ba363d338dd0''',
  'organization_member sees their own identity'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is((SELECT count(*) FROM auth.identity), 1::bigint, 'team_admin Heerlen sees exactly 1 identity');
SELECT results_eq(
  'SELECT id FROM auth.identity',
  'SELECT identity_id FROM auth.app_user WHERE id = ''952a8a36-a986-4ef6-9d43-fddba534b0ed''',
  'team_admin Heerlen sees their own identity'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is((SELECT count(*) FROM auth.identity), 1::bigint, 'team_admin Sittard sees exactly 1 identity');
SELECT results_eq(
  'SELECT id FROM auth.identity',
  'SELECT identity_id FROM auth.app_user WHERE id = ''ee07d2a9-050a-45d1-9db2-59f4a1f809d1''',
  'team_admin Sittard sees their own identity'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is((SELECT count(*) FROM auth.identity), 1::bigint, 'team_member Heerlen sees exactly 1 identity');
SELECT results_eq(
  'SELECT id FROM auth.identity',
  'SELECT identity_id FROM auth.app_user WHERE id = ''6c08321a-0a5f-4045-a3cd-4888460591a1''',
  'team_member Heerlen sees their own identity'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is((SELECT count(*) FROM auth.identity), 1::bigint, 'team_member Sittard sees exactly 1 identity');
SELECT results_eq(
  'SELECT id FROM auth.identity',
  'SELECT identity_id FROM auth.app_user WHERE id = ''92b7c8c7-0161-4319-a2b5-a5ca672879c1''',
  'team_member Sittard sees their own identity'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is((SELECT count(*) FROM auth.identity), 1::bigint, 'team_member Heerlen+Sittard sees exactly 1 identity');
SELECT results_eq(
  'SELECT id FROM auth.identity',
  'SELECT identity_id FROM auth.app_user WHERE id = ''b93ba2d4-ca5c-41ce-8817-f3b9dae568ed''',
  'team_member Heerlen+Sittard sees their own identity'
);

--------------
--- UPDATE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT results_eq(
  $$ UPDATE auth.identity
        SET password_hash = '$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f')
      RETURNING password_hash $$,
  $$ VALUES ('$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a') $$,
  'organization_admin can edit their own password'
);

SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ UPDATE auth.identity
        SET password_hash = 'hacked_other'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = 'f997d0b9-6210-44df-957a-ba363d338dd0')
      RETURNING password_hash $$,
  'organization_admin cannot edit the password of another user'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT results_eq(
  $$ UPDATE auth.identity
        SET password_hash = '$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = 'f997d0b9-6210-44df-957a-ba363d338dd0')
      RETURNING password_hash $$,
  $$ VALUES ('$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a') $$,
  'organization_member can edit their own password'
);

SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ UPDATE auth.identity
        SET password_hash = 'hacked_other'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f')
      RETURNING password_hash $$,
  'organization_member cannot edit the password of another user'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT results_eq(
  $$ UPDATE auth.identity
        SET password_hash = '$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = '952a8a36-a986-4ef6-9d43-fddba534b0ed')
      RETURNING password_hash $$,
  $$ VALUES ('$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a') $$,
  'team_admin Heerlen can edit their own password'
);

SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ UPDATE auth.identity
        SET password_hash = 'hacked_other'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1')
      RETURNING password_hash $$,
  'team_admin Heerlen cannot edit the password of another user'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT results_eq(
  $$ UPDATE auth.identity
        SET password_hash = '$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1')
      RETURNING password_hash $$,
  $$ VALUES ('$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a') $$,
  'team_admin Sittard can edit their own password'
);

SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ UPDATE auth.identity
        SET password_hash = 'hacked_other'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = '952a8a36-a986-4ef6-9d43-fddba534b0ed')
      RETURNING password_hash $$,
  'team_admin Sittard cannot edit the password of another user'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT results_eq(
  $$ UPDATE auth.identity
        SET password_hash = '$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = '6c08321a-0a5f-4045-a3cd-4888460591a1')
      RETURNING password_hash $$,
  $$ VALUES ('$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a') $$,
  'team_member Heerlen can edit their own password'
);

SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ UPDATE auth.identity
        SET password_hash = 'hacked_other'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1')
      RETURNING password_hash $$,
  'team_member Heerlen cannot edit the password of another user'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT results_eq(
  $$ UPDATE auth.identity
        SET password_hash = '$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1')
      RETURNING password_hash $$,
  $$ VALUES ('$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a') $$,
  'team_member Sittard can edit their own password'
);

SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ UPDATE auth.identity
        SET password_hash = 'hacked_other'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = '6c08321a-0a5f-4045-a3cd-4888460591a1')
      RETURNING password_hash $$,
  'team_member Sittard cannot edit the password of another user'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT results_eq(
  $$ UPDATE auth.identity
        SET password_hash = '$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed')
      RETURNING password_hash $$,
  $$ VALUES ('$2a$12$QyECOGXJfmCGHGaTnhP7eOKNAPoOUDgR.Aykp46xLY9BekGrXzB8a') $$,
  'team_member Heerlen+Sittard can edit their own password'
);

SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ UPDATE auth.identity
        SET password_hash = 'hacked_other'
      WHERE id = (SELECT identity_id FROM auth.app_user WHERE id = '6c08321a-0a5f-4045-a3cd-4888460591a1')
      RETURNING password_hash $$,
  'team_member Heerlen+Sittard cannot edit the password of another user'
);

--------------
--- DELETE ---
--------------

-- 1. organization_admin
SET app.current_user_id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f';
SELECT is_empty(
  $$ DELETE FROM auth.identity
      WHERE id = '0225f4be-0dd5-4a59-9bb8-a187c4a0390f'
      RETURNING id $$,
  'organization_admin delete returns no rows'
);

-- 2. organization_member
SET app.current_user_id = 'f997d0b9-6210-44df-957a-ba363d338dd0';
SELECT is_empty(
  $$ DELETE FROM auth.identity
      WHERE id = 'f997d0b9-6210-44df-957a-ba363d338dd0'
      RETURNING id $$,
  'organization_member delete returns no rows'
);

-- 3. team_admin Heerlen
SET app.current_user_id = '952a8a36-a986-4ef6-9d43-fddba534b0ed';
SELECT is_empty(
  $$ DELETE FROM auth.identity
      WHERE id = '952a8a36-a986-4ef6-9d43-fddba534b0ed'
      RETURNING id $$,
  'team_admin Heerlen delete returns no rows'
);

-- 4. team_admin Sittard
SET app.current_user_id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1';
SELECT is_empty(
  $$ DELETE FROM auth.identity
      WHERE id = 'ee07d2a9-050a-45d1-9db2-59f4a1f809d1'
      RETURNING id $$,
  'team_admin Sittard delete returns no rows'
);

-- 5. team_member Heerlen
SET app.current_user_id = '6c08321a-0a5f-4045-a3cd-4888460591a1';
SELECT is_empty(
  $$ DELETE FROM auth.identity
      WHERE id = '6c08321a-0a5f-4045-a3cd-4888460591a1'
      RETURNING id $$,
  'team_member Heerlen delete returns no rows'
);

-- 6. team_member Sittard
SET app.current_user_id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1';
SELECT is_empty(
  $$ DELETE FROM auth.identity
      WHERE id = '92b7c8c7-0161-4319-a2b5-a5ca672879c1'
      RETURNING id $$,
  'team_member Sittard delete returns no rows'
);

-- 7. team_member Heerlen + Sittard
SET app.current_user_id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed';
SELECT is_empty(
  $$ DELETE FROM auth.identity
      WHERE id = 'b93ba2d4-ca5c-41ce-8817-f3b9dae568ed'
      RETURNING id $$,
  'team_member Heerlen+Sittard delete returns no rows'
);

SELECT * FROM finish();

ROLLBACK;
