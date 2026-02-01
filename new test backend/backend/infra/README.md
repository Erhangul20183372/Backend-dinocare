# Infra (AWS SAM)

Run all Lambdas locally with SAM while consuming the monorepo shared package.

## Commands

- Build: `sam build -t infra/template.yaml --beta-features`
- Start API: `sam local start-api -t infra/template.yaml --port 3000 --warm-containers EAGER`

## Notes

- `functions/*` can import `@shared/ts/*`. During `sam build`, we pack `packages/shared-ts` and install it in each function via a tarball so esbuild can resolve it.
- During local dev (`pnpm dev`), declare workspace deps as normal (workspace:). For SAM builds, add a parallel file reference in the function’s package.json, e.g.:
  - "@shared/ts": "file:./shared-ts.tgz"
    The `prep-shared.mjs` script automatically packs all referenced workspace packages and copies tarballs into each function directory before `sam build`.
- If you change shared code, rebuild it: `pnpm -w --filter @shared/ts build`.
