include .env

.PHONY: help docker terraform db migrate seed test reset dev db-up db-down db-status db-clear tf-init tf-workspace tf-plan tf-apply tf-fmt tf-validate tf-import-test-roles migrate-new migrate-up migrate-down migrate-dump seed-% create-test-db migrate-test-up test-init dev db-reset

.DEFAULT_GOAL := help

# ----------------------------------------
# Vars
# ----------------------------------------

PROJECT             := $(notdir $(CURDIR))
DOCKER              ?= docker
COMPOSE             := $(DOCKER) compose
EXECUTE			    := $(DOCKER) exec -i
DOCKER_RUN          := $(COMPOSE) run --rm
DOCKER_RUN_SHELL    := $(DOCKER_RUN) --entrypoint ""

POSTGRES_CONTAINER  := dinocare-postgres
PGADMIN_CONTAINER   := dinocare-pgadmin
TERRAFORM_CONTAINER := dinocare-terraform
POSTGRES_VOLUME     := $(PROJECT)_postgres_data

DBMATE              := $(DOCKER_RUN) dbmate
PSQL_BASE           := $(EXECUTE) $(POSTGRES_CONTAINER) psql -U root
PSQL                := $(PSQL_BASE) -v ON_ERROR_STOP=1

WORKSPACE           ?= $(TF_WORKSPACE)
TF_ENV              := -e TF_VAR_db_name=$(if $(filter $(WORKSPACE),$(TF_TEST_WORKSPACE)),$(POSTGRES_TEST_NAME),$(POSTGRES_NAME))
TF                  := $(DOCKER_RUN_SHELL) $(TF_ENV) terraform terraform

SEED_DIR            ?= ../db/seeds
DATABASE            ?= $(POSTGRES_NAME)

TEST_DIR            ?= /tests
PG_PROVE            := $(DOCKER_RUN) -e PGPASSWORD=$(POSTGRES_BACKEND_PASSWORD) --entrypoint sh postgres -c

# ----------------------------------------
# Helpers
# ----------------------------------------

help: ## Show available targets
	@echo "Available targets:"
	@grep -h -E '^[a-zA-Z0-9._-]+:.*?## ' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "  %-25s %s\n", $$1, $$2}'

# ----------------------------------------
# Docker
# ----------------------------------------

db-up: ## Start Postgres and pgAdmin
	$(COMPOSE) up -d postgres pgadmin

db-down: ## Stop Postgres and pgAdmin
	-$(COMPOSE) stop postgres pgadmin || true

status: ## Show status of Postgres, pgAdmin, and Terraform
	$(COMPOSE) ps postgres pgadmin terraform || true

db-clear: ## Remove Postgres containers and volumes
	-$(COMPOSE) stop postgres pgadmin terraform || true
	-$(COMPOSE) rm -f postgres pgadmin terraform || true
	-$(DOCKER) volume rm -f $(POSTGRES_VOLUME) || true

# ----------------------------------------
# Terraform
# ----------------------------------------

tf-init: ## Initialize Terraform
	$(DOCKER_RUN_SHELL) terraform terraform init

tf-workspace: ## Select or create workspace
	$(DOCKER_RUN_SHELL) terraform terraform workspace select $(WORKSPACE) || \
	$(DOCKER_RUN_SHELL) terraform terraform workspace new $(WORKSPACE)

tf-plan: ## Run Terraform plan
	$(MAKE) tf-workspace
	$(TF) plan

tf-apply: ## Run Terraform apply
	$(MAKE) tf-workspace
	$(TF) apply -auto-approve

tf-fmt: ## Format Terraform files
	$(DOCKER_RUN_SHELL) terraform terraform fmt -recursive

tf-validate: ## Validate Terraform
	$(DOCKER_RUN_SHELL) terraform terraform validate

tf-import-test-roles: ## Import database roles into workspace
	$(MAKE) tf-workspace
	-$(DOCKER_RUN_SHELL) terraform terraform import postgresql_role.migrator db_migrator || true
	-$(DOCKER_RUN_SHELL) terraform terraform import postgresql_role.backend backend_user || true

# ----------------------------------------
# Database & Migrations
# ----------------------------------------

migrate-new: ## Create new migration (usage: make migrate-new name=add_table)
	@test -n "$(name)" || (echo "Usage: make migrate-new name=<migration_name>"; exit 1)
	$(DBMATE) new $(name)

migrate-up: ## Apply migrations
	$(DBMATE) up

migrate-down: ## Rollback last migration
	$(DBMATE) down

migrate-dump: ## Dump DB schema
	$(DBMATE) dump

migrate-rls: # Create RLS policies based on policies defined in infra/policies.json
	node ./scripts/generate-policies.mjs
# ----------------------------------------
# Seeds
# ----------------------------------------

seed-%: ## Seed database (usage: make seed-dev or make seed-test)
	$(PSQL_BASE) -d $(DATABASE) < $(SEED_DIR)/$*.sql

# ----------------------------------------
# Tests
# ----------------------------------------

create-test-db: ## Create test database
	$(MAKE) db-up
	-$(PSQL_BASE) -d postgres -c "CREATE DATABASE $(POSTGRES_TEST_NAME) OWNER $(POSTGRES_SUPERUSER_USER);"

migrate-test-up: ## Apply migrations to test DB
	$(DOCKER_RUN) -e DATABASE_URL=postgres://$(POSTGRES_MIGRATOR_USER):$(POSTGRES_MIGRATOR_PASSWORD)@$(POSTGRES_HOST):$(POSTGRES_PORT)/$(POSTGRES_TEST_NAME)?sslmode=disable dbmate up

test-init: ## Setup test environment
	$(MAKE) create-test-db
	$(MAKE) tf-init
	$(MAKE) tf-import-test-roles WORKSPACE=$(TF_TEST_WORKSPACE)
	$(MAKE) tf-apply WORKSPACE=$(TF_TEST_WORKSPACE)
	$(MAKE) migrate-test-up
	$(MAKE) seed-test DATABASE=$(POSTGRES_TEST_NAME)

test: ## Run all pgTAP tests
	$(PG_PROVE) "pg_prove -d $(POSTGRES_TEST_NAME) -U $(POSTGRES_BACKEND_USER) -h $(POSTGRES_HOST) -p $(POSTGRES_PORT) $(TEST_DIR)/*.sql"

test-file: ## Run a single pgTAP test file (usage: make test-file file=client_rls.sql)
	$(PG_PROVE) "pg_prove -d $(POSTGRES_TEST_NAME) -U $(POSTGRES_BACKEND_USER) -h $(POSTGRES_HOST) -p $(POSTGRES_PORT) $(TEST_DIR)/$(file)"

# ----------------------------------------
# Reset & Dev
# ----------------------------------------

dev: db-up tf-init tf-apply migrate-up seed-dev ## Start dev environment

db-reset: db-clear dev ## Reset dev DB
