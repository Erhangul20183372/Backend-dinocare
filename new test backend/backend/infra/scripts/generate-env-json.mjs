#!/usr/bin/env node
import { promises as fs } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, "..", "..");
const functionsDir = path.join(root, "functions");
const outputPath = path.join(root, "infra", "env.json");
const templatePath = path.join(root, "infra", "template.yaml");

function log(msg) {
  console.log(`[env:gen] ${msg}`);
}
function warn(msg) {
  console.warn(`[env:gen] WARN: ${msg}`);
}
function err(msg) {
  console.error(`[env:gen] ERROR: ${msg}`);
}

function pascalCase(name) {
  return name
    .split(/[\W_]+/)
    .filter(Boolean)
    .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
    .join("");
}

function parseDotenv(content) {
  const out = {};
  const lines = content.replace(/^\uFEFF/, "").split(/\r?\n/);
  for (const raw of lines) {
    let line = raw.trim();
    if (!line || line.startsWith("#")) continue;
    if (line.startsWith("export ")) line = line.slice(7);
    const eq = line.indexOf("=");
    if (eq === -1) continue;
    const key = line.slice(0, eq).trim();
    let value = line.slice(eq + 1);
    // Remove inline comments for unquoted values
    const isQuoted =
      value.length >= 2 &&
      ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'")));
    if (isQuoted) {
      value = value.slice(1, -1);
    } else {
      const hash = value.indexOf("#");
      if (hash !== -1) value = value.slice(0, hash);
      value = value.trim();
    }
    out[key] = String(value);
  }
  return out;
}

async function readIfExists(p) {
  try {
    return await fs.readFile(p, "utf8");
  } catch {
    return null;
  }
}

async function listFunctionDirs() {
  const entries = await fs.readdir(functionsDir, { withFileTypes: true }).catch(() => []);
  return entries.filter((e) => e.isDirectory()).map((e) => path.join(functionsDir, e.name));
}

async function collectEnvForFunction(fnDir) {
  const base = path.basename(fnDir);
  const dotenvPath = path.join(fnDir, ".env");
  const dotenvLocalPath = path.join(fnDir, ".env.local");

  const [baseEnv, localEnv] = await Promise.all([readIfExists(dotenvPath), readIfExists(dotenvLocalPath)]);
  if (!baseEnv && !localEnv) return null;

  const values = {};
  if (baseEnv) Object.assign(values, parseDotenv(baseEnv));
  if (localEnv) Object.assign(values, parseDotenv(localEnv));

  const logicalName = `${pascalCase(base)}Function`;
  return { logicalName, values };
}

async function main() {
  log(`Repo root: ${root}`);
  const fnDirs = await listFunctionDirs();
  if (!fnDirs.length) {
    warn("No functions/* directories found");
    return;
  }
  log(`Functions discovered: ${fnDirs.map((d) => path.basename(d)).join(", ")}`);

  const result = {};
  for (const dir of fnDirs) {
    const env = await collectEnvForFunction(dir);
    if (!env) {
      log(`No .env or .env.local in ${path.basename(dir)}, skipping`);
      continue;
    }
    result[env.logicalName] = env.values;
  }

  const json = JSON.stringify(result, null, 4) + "\n";
  await fs.writeFile(outputPath, json, "utf8");
  log(`Wrote ${path.relative(root, outputPath)} with ${Object.keys(result).length} functions`);

  // Validate against template.yaml declared environment variables
  const templateRaw = await readIfExists(templatePath);
  if (!templateRaw) {
    warn(`Could not read template.yaml at ${path.relative(root, templatePath)} — skipping env key validation`);
    return;
  }

  const expected = extractFunctionEnvVarsFromTemplate(templateRaw);
  validateEnvMatchesTemplate({ generated: result, expected });
}

main().catch((e) => {
  err(e?.stack || String(e));
  process.exit(1);
});

// --- Helpers for YAML template parsing & validation ---

function leadingSpacesCount(s) {
  let i = 0;
  while (i < s.length && s[i] === " ") i++;
  return i;
}

function extractFunctionEnvVarsFromTemplate(yamlText) {
  // Best-effort parser tailored to this repo's template.yaml structure
  const map = new Map();
  const lines = yamlText.split(/\r?\n/);

  let inResources = false;
  let resourcesIndent = 0;
  let currRes = null;
  let currResIndent = 0;
  let currIsFunction = false;
  let currVars = null;
  let varsIndent = null;

  function finalizeResource() {
    if (currRes && currIsFunction) {
      map.set(currRes, new Set(currVars || []));
    }
    currRes = null;
    currResIndent = 0;
    currIsFunction = false;
    currVars = null;
    varsIndent = null;
  }

  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    const line = raw.replace(/\t/g, "  ");
    const indent = leadingSpacesCount(line);
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;

    if (!inResources) {
      if (trimmed === "Resources:") {
        inResources = true;
        resourcesIndent = indent;
      }
      continue;
    }

    // Leaving Resources block
    if (indent <= resourcesIndent && trimmed.endsWith(":") && !trimmed.includes(" ")) {
      // Top-level key at or above resources indent (e.g., Outputs:)
      finalizeResource();
      break;
    }

    // New resource under Resources
    if (indent === resourcesIndent + 2 && trimmed.endsWith(":") && !trimmed.includes(" ")) {
      // Switch to a new resource
      finalizeResource();
      currRes = trimmed.slice(0, -1);
      currResIndent = indent;
      currIsFunction = false;
      currVars = null;
      varsIndent = null;
      continue;
    }

    if (!currRes) continue;

    // Only consider Type at resource level (avoid nested Event Type)
    if (indent === currResIndent + 2 && trimmed.startsWith("Type:")) {
      const typeVal = trimmed.slice("Type:".length).trim();
      currIsFunction = typeVal === "AWS::Serverless::Function";
      continue;
    }

    if (!currIsFunction) continue;

    // Capture Variables block and its keys
    if (trimmed === "Variables:") {
      varsIndent = indent;
      if (!currVars) currVars = [];
      continue;
    }

    if (varsIndent != null) {
      if (indent <= varsIndent) {
        // left the Variables block
        varsIndent = null;
      } else {
        // Expect KEY: [value]
        const m = trimmed.match(/^([A-Za-z0-9_]+)\s*:/);
        if (m) currVars.push(m[1]);
      }
    }
  }

  // flush last resource
  finalizeResource();

  return map;
}

function validateEnvMatchesTemplate({ generated, expected }) {
  const genFunctions = new Set(Object.keys(generated));
  const expectedFunctions = new Set(expected.keys());

  const notInTemplate = [...genFunctions].filter((n) => !expectedFunctions.has(n));
  const missingFunctions = [...expectedFunctions].filter((n) => !genFunctions.has(n));

  let mismatches = 0;

  for (const name of expectedFunctions) {
    const expectedKeys = expected.get(name) || new Set();
    const actualKeys = new Set(Object.keys(generated[name] || {}));
    const missing = [...expectedKeys].filter((k) => !actualKeys.has(k));
    const extra = [...actualKeys].filter((k) => !expectedKeys.has(k));
    if (missing.length || extra.length) {
      mismatches++;
      err(`Env var mismatch for ${name}`);
      if (missing.length) warn(`  Missing in env.json: ${missing.join(", ")}`);
      if (extra.length) warn(`  Extra in env.json: ${extra.join(", ")}`);
    }
  }

  if (notInTemplate.length) {
    warn(`Functions in env.json but not in template: ${notInTemplate.join(", ")}`);
  }
  if (missingFunctions.length) {
    warn(`Functions in template without env.json section: ${missingFunctions.join(", ")}`);
  }

  if (mismatches > 0) {
    err("Environment variables in env.json do not match template.yaml. Please align the keys.");
    process.exit(1);
  }
}
