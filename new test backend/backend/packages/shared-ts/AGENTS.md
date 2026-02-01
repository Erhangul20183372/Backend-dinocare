# AGENTS.md

Agent instructions for the `shared-ts` TypeScript utilities package.

## Overview

- Shared TypeScript code for Lambda functions and other packages.
- Provides utilities and middlewares for Express.

## Setup Commands

- Install dependencies: `pnpm install`
- Build: `pnpm build` or `tsc -p tsconfig.json`
- Clean: `pnpm clean`

## Code Style

- TypeScript strict mode
- Use single quotes, no semicolons
- Prefer functional patterns

## Testing Instructions

- Add tests in `src/` and update `test` script
- Run typecheck: `pnpm typecheck`
- Lint: `pnpm lint`

## PR Instructions

- PR title: `[shared-ts] <Title>`
- Run lint and typecheck before committing

## Notes

- Exports types and middlewares for use in functions
- Update dependencies in `package.json` as needed

---

See root AGENTS.md for monorepo-wide rules.
