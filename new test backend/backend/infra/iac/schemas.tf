resource "postgresql_schema" "app" {
  name     = "app"
  owner    = var.migrator_user
  database = var.db_name

  depends_on = [
    postgresql_role.migrator
  ]
}

resource "postgresql_schema" "auth" {
  name     = "auth"
  owner    = var.migrator_user
  database = var.db_name

  depends_on = [
    postgresql_role.migrator
  ]
}

resource "postgresql_schema" "organization" {
  name     = "organization"
  owner    = var.migrator_user
  database = var.db_name

  depends_on = [
    postgresql_role.migrator
  ]
}

resource "postgresql_schema" "team" {
  name     = "team"
  owner    = var.migrator_user
  database = var.db_name

  depends_on = [
    postgresql_role.migrator
  ]
}

resource "postgresql_schema" "client" {
  name     = "client"
  owner    = var.migrator_user
  database = var.db_name

  depends_on = [
    postgresql_role.migrator
  ]
}

resource "postgresql_schema" "device" {
  name     = "device"
  owner    = var.migrator_user
  database = var.db_name

  depends_on = [
    postgresql_role.migrator
  ]
}