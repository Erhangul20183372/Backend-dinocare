#!/usr/bin/env node
import fs from "fs";
import path from "path";

const inputPath = path.resolve("../docs/rls/policies.json");
const outputDir = path.resolve("../db/generated");
const snapshotPath = path.join(outputDir, "policies.snapshot.json");
const migrationDir = path.resolve("../db/migrations");

if (!fs.existsSync(inputPath)) {
  console.error(`File not found: ${inputPath}`);
  process.exit(1);
}
if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });
if (!fs.existsSync(migrationDir)) fs.mkdirSync(migrationDir, { recursive: true });

const data = JSON.parse(fs.readFileSync(inputPath, "utf8"));
const previous = fs.existsSync(snapshotPath) ? JSON.parse(fs.readFileSync(snapshotPath, "utf8")) : {};

const opMap = {
  create: "INSERT",
  read: "SELECT",
  update: "UPDATE",
  delete: "DELETE",
};

const opToClauses = {
  create: { using: false, check: true },
  read: { using: true, check: false },
  update: { using: true, check: true },
  delete: { using: true, check: false },
};

const roleToFunction = {
  app_admin: () => `app.has_root_role('app_admin'::role)`,
  app_member: () => `app.has_root_role('app_member'::role)`,
  organization_admin: () => `app.has_org_role('organization_admin'::role)`,
  organization_member: () => `app.has_org_role('organization_member'::role)`,
  team_admin: () => `app.has_team_role('team_admin'::role)`,
  team_member: () => `app.has_team_role('team_member'::role)`,
  client_member: () => `app.has_client_role('client_member'::role)`,
};

const scopeToFunction = {
  identity: {
    self: (op) => `app.identity__scope__self(id, '${op}')`,
  },

  app_user: {
    self: (op) => `app.app_user__scope__self(id, '${op}')`,
    organization: (op) => `app.app_user__scope__organization(id, '${op}')`,
    team: (op) => `app.app_user__scope__team(id, '${op}')`,
  },

  app_user_organization_membership: {
    self: (op) => `app.app_user_organization_membership__scope__self(app_user_id, organization_id, '${op}')`,
    organization: (op) =>
      `app.app_user_organization_membership__scope__organization(app_user_id, organization_id, '${op}')`,
  },

  organization: {
    self: (op) => `app.organization__scope__self(id, '${op}')`,
  },

  app_user_team_membership: {
    self: (op) => `app.app_user_team_membership__scope__self(app_user_id, team_id, '${op}')`,
    organization: (op) => `app.app_user_team_membership__scope__organization(app_user_id, team_id, '${op}')`,
    team: (op) => `app.app_user_team_membership__scope__team(app_user_id, team_id, '${op}')`,
  },

  team: {
    self: (op) => `app.team__scope__self(id, '${op}')`,
    organization: (op) => `app.team__scope__organization(organization_id, '${op}')`,
  },

  app_user_client_membership: {
    self: (op) => `app.app_user_client_membership__scope__self(app_user_id, client_id, '${op}')`,
  },

  client: {
    self: (op) => `app.client__scope__self(id, '${op}')`,
    organization: (op) => `app.client__scope__organization(team_id, '${op}')`,
    team: (op) => `app.client__scope__team(team_id, '${op}')`,
  },

  client_device_assignment: {
    self: (op) => `app.client_device_assignment__scope__self(client_id, '${op}')`,
    organization: (op) => `app.client_device_assignment__scope__organization(client_id, '${op}')`,
    team: (op) => `app.client_device_assignment__scope__team(client_id, '${op}')`,
  },

  device: {
    self: (op) => `app.device__scope__self(id, '${op}')`,
    organization: (op) => `app.device__scope__organization(id, '${op}')`,
    team: (op) => `app.device__scope__team(id, '${op}')`,
  },
};

function toCondition(table, role, scope, op) {
  const entity = table.split(".").pop();
  const roleExpr = roleToFunction[role]?.() ?? "FALSE";
  if (scope === "global") return `(${roleExpr})`;
  const scopeFn = scopeToFunction[entity]?.[scope];
  const scopeExpr = scopeFn ? scopeFn(op) : "FALSE";
  return `(${roleExpr} AND ${scopeExpr})`;
}

function buildPolicyBody(op, conds) {
  const { using, check } = opToClauses[op];
  const parts = [];
  const expr = conds || "FALSE";
  if (using) parts.push(`USING (${expr})`);
  if (check) parts.push(`WITH CHECK (${expr})`);
  return parts.join("\n      ");
}

for (const [table, ops] of Object.entries(data)) {
  let sql = `-- Generated policies for ${table}\n`;

  for (const [op, entries] of Object.entries(ops)) {
    const opSql = opMap[op];
    const conds = (entries || []).map(({ role, scope }) => toCondition(table, role, scope, op)).join(" OR ");
    const body = buildPolicyBody(op, conds);

    sql += `
      CREATE POLICY ${table.replace(/\./g, "_")}_${op}
      ON ${table}
      FOR ${opSql}
      ${body};
    `;
  }

  const outFile = path.join(outputDir, `${table.replace(/\./g, "_")}.sql`);
  fs.writeFileSync(outFile, sql.trim() + "\n");
  console.log(`${outFile}`);
}

let upSQL = "";
let downSQL = "";

for (const [table, ops] of Object.entries(data)) {
  const oldOps = previous[table] || {};
  for (const [op, entries] of Object.entries(ops)) {
    const oldEntries = oldOps[op] || [];
    if (JSON.stringify(entries) !== JSON.stringify(oldEntries)) {
      const opSql = opMap[op];
      const conds = (entries || []).map(({ role, scope }) => toCondition(table, role, scope, op)).join(" OR ");
      const body = buildPolicyBody(op, conds);
      const name = `${table.replace(/\./g, "_")}_${op}`;

      upSQL += `
        DROP POLICY IF EXISTS ${name} ON ${table};
        CREATE POLICY ${name} ON ${table} FOR ${opSql}
        ${body};
      `;
      downSQL += `\nDROP POLICY IF EXISTS ${name} ON ${table};\n`;
    }
  }
}

for (const [table, oldOps] of Object.entries(previous)) {
  if (!data[table]) {
    for (const op of Object.keys(oldOps)) {
      const name = `${table.replace(/\./g, "_")}_${op}`;
      downSQL += `\nDROP POLICY IF EXISTS ${name} ON ${table};\n`;
    }
  }
}

if (upSQL.trim()) {
  const file = `${new Date().toISOString().slice(0, 19).replace(/[-:]/g, "").replace("T", "")}_policy_changes.sql`;
  const outPath = path.join(migrationDir, file);
  fs.writeFileSync(outPath, `-- migrate:up\n${upSQL.trim()}\n\n-- migrate:down\n${downSQL.trim()}\n`);
  console.log(`Migration created: ${outPath}`);
} else {
  console.log("No policy changes detected.");
}

fs.writeFileSync(snapshotPath, JSON.stringify(data, null, 2));
console.log(`Snapshot updated: ${snapshotPath}`);
