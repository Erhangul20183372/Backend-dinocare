# AGENTS.md

Agent instructions for the `auth` Lambda function.

## Overview

- Node.js authentication Lambda function using Express and TypeScript.
- Depends on `@shared/ts` for shared utilities.

## Setup Commands

- Install dependencies: `pnpm install`
- Start local dev: `pnpm dev` (runs `tsx watch src/entrypoints/local.ts`)
- Build: `pnpm build` or `tsc -b`
- Clean: `pnpm clean`

## Code Style

- TypeScript strict mode (inherits from monorepo)
- Use single quotes, no semicolons
- Prefer functional patterns

## Testing Instructions

- No tests yet (add tests in `src/` and update `test` script)
- Run typecheck: `pnpm typecheck`
- Lint: `pnpm lint`

## PR Instructions

- PR title: `[auth] <Title>`
- Run lint and typecheck before committing

## Notes

- Uses Express 5 and Zod for validation
- Shared code imported from `@shared/ts`
- Update dependencies in `package.json` as needed

---

See root AGENTS.md for monorepo-wide rules.
