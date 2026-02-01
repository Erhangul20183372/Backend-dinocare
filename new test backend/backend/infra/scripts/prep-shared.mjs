#!/usr/bin/env node
import { execSync } from "node:child_process";
import { promises as fs } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

// Resolve repo root regardless of where this script is run from
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, "..", "..");
const pkgsDir = path.join(root, "packages");
const fnsDir = path.join(root, "functions");

function log(msg) {
  console.log(`[prep-shared] ${msg}`);
}
function warn(msg) {
  console.warn(`[prep-shared] WARN: ${msg}`);
}
function err(msg) {
  console.error(`[prep-shared] ERROR: ${msg}`);
}

async function readJson(p) {
  return JSON.parse(await fs.readFile(p, "utf8"));
}

async function listDirs(dir) {
  const entries = await fs.readdir(dir, { withFileTypes: true }).catch(() => []);
  return entries.filter((e) => e.isDirectory()).map((e) => path.join(dir, e.name));
}

async function getWorkspacePackages() {
  const dirs = await listDirs(pkgsDir);
  const map = new Map(); // name -> dir
  for (const d of dirs) {
    const pkgPath = path.join(d, "package.json");
    try {
      const pkg = await readJson(pkgPath);
      if (pkg?.name) map.set(pkg.name, d);
    } catch {}
  }
  return map;
}

async function ensureBuilt(pkgDir) {
  // If prepack exists, npm pack will handle build. Otherwise, build if possible.
  try {
    const pkg = await readJson(path.join(pkgDir, "package.json"));
    const distDir = path.join(pkgDir, "dist");
    // If dist missing and build script exists and no prepack, run build.
    const hasPrepack = pkg.scripts && pkg.scripts.prepack;
    const hasBuild = pkg.scripts && pkg.scripts.build;
    let distExists = false;
    try {
      await fs.access(distDir);
      distExists = true;
    } catch {}
    if (!hasPrepack && hasBuild && !distExists) {
      log(`Building workspace package ${pkg.name} (no prepack, dist missing)`);
      execSync("npm run build", { cwd: pkgDir, stdio: "inherit" });
    }
  } catch {}
}

async function packPackage(pkgDir) {
  // Run npm pack and capture the tarball file name
  await ensureBuilt(pkgDir);
  const out = execSync("npm pack --silent", { cwd: pkgDir, encoding: "utf8" }).trim();
  const tarball = out.split("\n").pop();
  return path.join(pkgDir, tarball);
}

function isTgzFileRef(spec) {
  return typeof spec === "string" && spec.startsWith("file:./") && spec.endsWith(".tgz");
}

async function main() {
  log(`Root: ${root}`);
  log(`Packages dir: ${pkgsDir}`);
  log(`Functions dir: ${fnsDir}`);
  const workspacePkgs = await getWorkspacePackages();
  log(`Workspace packages found: ${workspacePkgs.size}`);
  const fnDirs = await listDirs(fnsDir);
  log(`Functions found: ${fnDirs.length}`);
  if (!fnDirs.length) {
    log("No functions found.");
    return;
  }

  // Cache tarballs per workspace package to avoid packing multiple times
  const tarballCache = new Map(); // depName -> tarballPath
  const createdTarballs = new Set(); // absolute paths to clean up later
  const missingSpecs = []; // collect problems and fail once

  for (const fn of fnDirs) {
    const pkgJsonPath = path.join(fn, "package.json");
    let pkg;
    try {
      pkg = await readJson(pkgJsonPath);
    } catch {
      continue;
    }

    const deps = { ...(pkg.dependencies || {}), ...(pkg.devDependencies || {}) };
    const allEntries = Object.entries(deps);
    // Fail-fast: any dep that is a workspace package but not a file:./*.tgz spec
    for (const [depName, spec] of allEntries) {
      if (workspacePkgs.has(depName) && !isTgzFileRef(spec)) {
        missingSpecs.push({ fn: path.basename(fn), depName, spec });
      }
    }
    const entries = allEntries.filter(([name, spec]) => isTgzFileRef(spec));
    if (!entries.length) continue;

    for (const [depName, spec] of entries) {
      if (!workspacePkgs.has(depName)) {
        warn(`${depName} not found in packages/`);
        continue;
      }
      const srcDir = workspacePkgs.get(depName);
      let srcTgz = tarballCache.get(depName);
      if (!srcTgz) {
        srcTgz = await packPackage(srcDir);
        tarballCache.set(depName, srcTgz);
        createdTarballs.add(srcTgz);
      }
      const destRel = spec.replace("file:", ""); // ./<name>.tgz
      const destAbs = path.join(fn, destRel);
      await fs.copyFile(srcTgz, destAbs);
      log(`Copied ${path.basename(srcTgz)} -> ${path.relative(root, destAbs)} for ${depName}`);
    }
  }

  // Cleanup created tarballs in packages/*
  for (const tgz of createdTarballs) {
    try {
      await fs.unlink(tgz);
    } catch {}
  }

  if (missingSpecs.length) {
    err(
      'Some functions depend on workspace packages without file:./*.tgz spec. Update function package.json to add a file tgz entry, e.g. "@shared/ts": "file:./shared-ts.tgz"'
    );
    for (const m of missingSpecs) {
      err(` - function=${m.fn}, dep=${m.depName}, currentSpec=${m.spec}`);
    }
    process.exit(1);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
