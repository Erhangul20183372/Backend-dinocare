-- migrate:up

CREATE FUNCTION app.lookup_identity(_email citext)
RETURNS TABLE(id uuid, password_hash text, email_address citext)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT id, password_hash, email_address
  FROM auth.identity
  WHERE email_address = _email;
$$;

CREATE FUNCTION app.lookup_app_user(_identity_id uuid)
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT u.id
  FROM auth.app_user u
  WHERE u.identity_id = _identity_id;
$$;

-- migrate:down

DROP FUNCTION IF EXISTS app.lookup_identity(citext);
DROP FUNCTION IF EXISTS app.lookup_app_user(uuid);
