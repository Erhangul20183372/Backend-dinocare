# Serverless Backend Monorepo

Node.js Lambda functions, shared TypeScript libraries, and AWS SAM infra in a pnpm + Turborepo workspace.

## Structure

```
.
├─ functions/                  # Lambda functions (per-folder CodeUri)
│  └─ auth/
│     ├─ src/entrypoints/      # lambda.ts (handler) + local.ts (dev server)
│     ├─ src/**                # express app, routes, services
│     ├─ tsconfig.json         # project tsconfig
│     └─ tsconfig.sambuild.json# used by SAM esbuild bundler
├─ packages/
│  └─ shared-ts/               # shared TypeScript lib (exports middlewares, utils)
├─ infra/                      # SAM template, config, and scripts
│  ├─ template.yaml            # SAM HttpApi + Functions
│  ├─ samconfig.toml           # SAM defaults
│  └─ scripts/prep-shared.mjs  # packs shared libs into functions for SAM
├─ pnpm-workspace.yaml
├─ turbo.json
└─ package.json                # workspace scripts (proxy to infra)
```

## Prereqs

- pnpm installed
- AWS SAM CLI installed (sam --version)
- Node.js 20.x runtime (Lambda target)

## Install & Build

```bash
pnpm install
pnpm build      # turbo build all packages & functions
```

## Local development (fast loop)

Functions run with tsx and link the shared package via pnpm workspaces.

```bash
pnpm dev        # runs turbo dev; functions/auth listens on :3000 (local.ts)
```

Edit code in packages/shared-ts and functions/\* and see changes immediately.

## SAM local (emulates API Gateway + Lambda)

We keep SAM files in infra/. Root scripts proxy to infra.

```bash
# Build (packs shared libs and builds SAM artifacts)
pnpm sam:build

# Start local HttpApi (after build)
pnpm sam:start
```

Under the hood:

- infra/scripts/prep-shared.mjs packs every referenced shared package and copies a tarball into each function that declares a file: ./<name>.tgz dependency.
- SAM esbuild bundles from each function’s CodeUri (e.g., functions/auth), using tsconfig.sambuild.json.

## Shared libraries strategy

- Dev (pnpm): workspace linking for instant changes.
  - Root package.json has pnpm.overrides ("@shared/_": "workspace:_") to force workspace resolution in dev.
- SAM build (npm): npm doesn’t understand workspace: protocol.
  - In each function that uses a shared lib, add a matching tarball dep, e.g.:
    - "@shared/ts": "file:./shared-ts.tgz"
  - prep-shared.mjs will npm pack packages/shared-ts and copy the tarball into the function before sam build.

Notes:

- Generated tarballs under functions/_/_.tgz are ignored by git.
- shared-ts has a prepack/build; make sure dist exists for packing.

## Adding a new function

1. Create folder under functions/<name> with:

- src/entrypoints/lambda.ts exporting `handler`
- src/entrypoints/local.ts for express dev server
- tsconfig.json + (optional) tsconfig.sambuild.json

2. Wire it in infra/template.yaml:

```
<Name>Function:
  Type: AWS::Serverless::Function
  Properties:
    CodeUri: ../functions/<name>
    Handler: src/entrypoints/lambda.handler
    Events:
      AnyRoute:
        Type: HttpApi
        Properties:
          ApiId: !Ref Api
          Path: /<name>/{proxy+}
          Method: ANY
  Metadata:
    BuildMethod: esbuild
    BuildProperties:
      EntryPoints: [src/entrypoints/lambda.ts]
      Target: node20
      Tsconfig: tsconfig.sambuild.json
```

3. If it uses shared libs, add file: deps like "@shared/ts": "file:./shared-ts.tgz".

## Adding a new shared package

Create under packages/<pkg> with proper exports and a prepack/build that outputs dist/.

```bash
pnpm --filter packages/shared-xyz init
pnpm --filter packages/shared-xyz add -D typescript rimraf
```

## Troubleshooting

- npm error Unsupported URL Type "workspace:":
  - Ensure functions declare shared deps with file: ./<name>.tgz for SAM builds.
  - Run: pnpm run sam:build (which runs prep-shared first).

- SAM can’t find function entrypoint:
  - Check CodeUri path in infra/template.yaml and that src/entrypoints/lambda.ts exists.
  - Ensure BuildProperties.EntryPoints matches the handler file.

- Shared imports not resolved by esbuild:
  - Confirm the shared tarball is present in the function folder.
  - Verify tsconfig.sambuild.json doesn’t rely on monorepo base paths.

## Scripts (shortcuts)

- pnpm dev — turbo dev (parallel) for fast local express servers
- pnpm build — turbo build for all
- pnpm run sam:build — proxy to infra (packs shared + sam build)
- pnpm run sam:start — proxy to infra (start-api after build)
