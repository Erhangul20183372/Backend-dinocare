resource "postgresql_role" "migrator" {
  name     = var.migrator_user
  login    = true
  password = var.migrator_password
}

resource "postgresql_role" "backend" {
  name     = var.backend_user
  login    = true
  password = var.backend_password
}
