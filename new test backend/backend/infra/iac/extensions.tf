resource "postgresql_extension" "pgcrypto" {
  name     = "pgcrypto"
  database = var.db_name
}

resource "postgresql_extension" "btree_gist" {
  name     = "btree_gist"
  database = var.db_name
}

resource "postgresql_extension" "citext" {
  name     = "citext"
  database = var.db_name
}

resource "postgresql_extension" "pgtap" {
  count    = terraform.workspace == "testing" ? 1 : 0
  name     = "pgtap"
  database = var.db_name
}
