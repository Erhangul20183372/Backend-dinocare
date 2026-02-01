terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.22"
    }
  }
}

provider "postgresql" {
  host     = var.db_host
  port     = tonumber(var.db_port)
  database = var.db_name
  username = var.db_admin_user
  password = var.db_admin_pass
  sslmode  = "disable"
}
