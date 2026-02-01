# ========== PUBLIC ==========

# ========== MIGRATOR

resource "postgresql_grant" "migrator_schema_public" {
  database    = var.db_name
  schema      = "public"
  role        = var.migrator_user
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
  depends_on  = [postgresql_role.migrator, postgresql_role.backend]
}

# ========== BACKEND

resource "postgresql_grant" "backend_schema_public" {
  database    = var.db_name
  schema      = "public"
  role        = var.backend_user
  object_type = "schema"
  privileges  = ["USAGE"]
  depends_on  = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_public]
}

resource "postgresql_grant" "backend_tables_public" {
  database    = var.db_name
  schema      = "public"
  role        = var.backend_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

resource "postgresql_grant" "backend_sequences_public" {
  database    = var.db_name
  schema      = "public"
  role        = var.backend_user
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

resource "postgresql_default_privileges" "backend_tables_public" {
  database    = var.db_name
  schema      = "public"
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

resource "postgresql_default_privileges" "backend_sequences_public" {
  database    = var.db_name
  schema      = "public"
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

resource "postgresql_default_privileges" "backend_functions_public" {
  database    = var.db_name
  schema      = "public"
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "function"
  privileges  = ["EXECUTE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

# ==============================

# ========== APP ==========

# ========== MIGRATOR

resource "postgresql_grant" "migrator_schema_app" {
  database    = var.db_name
  schema      = postgresql_schema.app.name
  role        = var.migrator_user
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

# ========== BACKEND

resource "postgresql_grant" "backend_schema_app" {
  database    = var.db_name
  schema      = postgresql_schema.app.name
  role        = var.backend_user
  object_type = "schema"
  privileges  = ["USAGE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

resource "postgresql_grant" "backend_functions_app" {
  database    = var.db_name
  schema      = postgresql_schema.app.name
  role        = var.backend_user
  object_type = "function"
  privileges  = ["EXECUTE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

resource "postgresql_grant" "backend_tables_app" {
  database    = var.db_name
  schema      = postgresql_schema.app.name
  role        = var.backend_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}


resource "postgresql_default_privileges" "backend_functions_app" {
  database    = var.db_name
  schema      = postgresql_schema.app.name
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "function"
  privileges  = ["EXECUTE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}


resource "postgresql_default_privileges" "backend_tables_app" {
  database    = var.db_name
  schema      = postgresql_schema.app.name
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

# ==============================

# ========== AUTH ==========

# ========== MIGRATOR

resource "postgresql_grant" "migrator_schema_auth" {
  database    = var.db_name
  schema      = postgresql_schema.auth.name
  role        = var.migrator_user
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_app]
}

# ========== BACKEND

resource "postgresql_grant" "backend_schema_auth" {
  database    = var.db_name
  schema      = postgresql_schema.auth.name
  role        = var.backend_user
  object_type = "schema"
  privileges  = ["USAGE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_auth]
}

resource "postgresql_grant" "backend_tables_auth" {
  database    = var.db_name
  schema      = postgresql_schema.auth.name
  role        = var.backend_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_auth]
}

resource "postgresql_grant" "backend_sequences_auth" {
  database    = var.db_name
  schema      = postgresql_schema.auth.name
  role        = var.backend_user
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_auth]
}

resource "postgresql_default_privileges" "backend_tables_auth" {
  database    = var.db_name
  schema      = postgresql_schema.auth.name
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_auth]
}

resource "postgresql_default_privileges" "backend_sequences_auth" {
  database    = var.db_name
  schema      = postgresql_schema.auth.name
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_auth]
}

resource "postgresql_default_privileges" "backend_functions_auth" {
  database    = var.db_name
  schema      = postgresql_schema.app.name
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "function"
  privileges  = ["EXECUTE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_auth]
}

# ========== CLIENT ==========

# ========== MIGRATOR

resource "postgresql_grant" "migrator_schema_client" {
  database    = var.db_name
  schema      = postgresql_schema.client.name
  role        = var.migrator_user
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_auth]
}

# ========== BACKEND

resource "postgresql_grant" "backend_schema_client" {
  database    = var.db_name
  schema      = postgresql_schema.client.name
  role        = var.backend_user
  object_type = "schema"
  privileges  = ["USAGE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_client]
}

resource "postgresql_grant" "backend_tables_client" {
  database    = var.db_name
  schema      = postgresql_schema.client.name
  role        = var.backend_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_auth]
}

resource "postgresql_grant" "backend_sequences_client" {
  database    = var.db_name
  schema      = postgresql_schema.client.name
  role        = var.backend_user
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_auth]
}

resource "postgresql_default_privileges" "backend_tables_client" {
  database    = var.db_name
  schema      = postgresql_schema.client.name
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_auth]
}

resource "postgresql_default_privileges" "backend_sequences_client" {
  database    = var.db_name
  schema      = postgresql_schema.client.name
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_auth]
}

# ==============================

# ========== DEVICE ==========

# ========== MIGRATOR

resource "postgresql_grant" "migrator_schema_device" {
  database    = var.db_name
  schema      = postgresql_schema.device.name
  role        = var.migrator_user
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_auth]
}

# ========== BACKEND

resource "postgresql_grant" "backend_schema_device" {
  database    = var.db_name
  schema      = postgresql_schema.device.name
  role        = var.backend_user
  object_type = "schema"
  privileges  = ["USAGE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_device]
}

resource "postgresql_grant" "backend_tables_device" {
  database    = var.db_name
  schema      = postgresql_schema.device.name
  role        = var.backend_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

resource "postgresql_grant" "backend_sequences_device" {
  database    = var.db_name
  schema      = postgresql_schema.device.name
  role        = var.backend_user
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

resource "postgresql_default_privileges" "backend_tables_device" {
  database    = var.db_name
  schema      = postgresql_schema.device.name
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

resource "postgresql_default_privileges" "backend_sequences_device" {
  database    = var.db_name
  schema      = postgresql_schema.device.name
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

# ==============================

# ========== ORGANIZATION ==========

# ========== MIGRATOR

resource "postgresql_grant" "migrator_schema_organization" {
  database    = var.db_name
  schema      = postgresql_schema.organization.name
  role        = var.migrator_user
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

# ========== BACKEND

resource "postgresql_grant" "backend_schema_organization" {
  database    = var.db_name
  schema      = postgresql_schema.organization.name
  role        = var.backend_user
  object_type = "schema"
  privileges  = ["USAGE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

resource "postgresql_grant" "backend_tables_organization" {
  database    = var.db_name
  schema      = postgresql_schema.organization.name
  role        = var.backend_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

resource "postgresql_grant" "backend_sequences_organization" {
  database    = var.db_name
  schema      = postgresql_schema.organization.name
  role        = var.backend_user
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

resource "postgresql_default_privileges" "backend_tables_organization" {
  database    = var.db_name
  schema      = postgresql_schema.organization.name
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

resource "postgresql_default_privileges" "backend_sequences_organization" {
  database    = var.db_name
  schema      = postgresql_schema.organization.name
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

# ==============================

# ========== TEAM ==========

# ========== MIGRATOR

resource "postgresql_grant" "migrator_schema_team" {
  database    = var.db_name
  schema      = postgresql_schema.team.name
  role        = var.migrator_user
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend]
}

# ========== BACKEND

resource "postgresql_grant" "backend_schema_team" {
  database    = var.db_name
  schema      = postgresql_schema.team.name
  role        = var.backend_user
  object_type = "schema"
  privileges  = ["USAGE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_team]
}

resource "postgresql_grant" "backend_tables_team" {
  database    = var.db_name
  schema      = postgresql_schema.team.name
  role        = var.backend_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_team]
}

resource "postgresql_grant" "backend_sequences_team" {
  database    = var.db_name
  schema      = postgresql_schema.team.name
  role        = var.backend_user
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_team]
}

resource "postgresql_default_privileges" "backend_tables_team" {
  database    = var.db_name
  schema      = postgresql_schema.team.name
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_team]
}

resource "postgresql_default_privileges" "backend_sequences_team" {
  database    = var.db_name
  schema      = postgresql_schema.team.name
  role        = var.backend_user
  owner       = var.migrator_user
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
  depends_on = [postgresql_role.migrator, postgresql_role.backend, postgresql_grant.migrator_schema_team]
}

# ==============================