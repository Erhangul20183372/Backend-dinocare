# AGENTS.md

This file provides agent-focused instructions for working with the dinocare serverless backend monorepo. It complements README.md by offering build, test, and code style guidance for coding agents and automation tools.

## Project Overview

- Monorepo managed with `pnpm` workspaces and Turborepo.
- Main folders:
  - `functions/` — AWS Lambda functions (Node.js/TypeScript)
    - Example: `auth/` (authentication service)
  - `packages/` — Shared libraries
    - `shared-ts/` (TypeScript utilities)
    - `shared-py/` (Python utilities)

## Setup Commands

- Install all dependencies: `pnpm install`
- Build all packages/functions: `pnpm build`
- Start dev server (parallel): `pnpm dev`
- Clean all build outputs: `pnpm clean`

## Working with Packages & Functions

- Add a dependency to shared TypeScript library:
  `pnpm --filter @shared/ts add <package>`
- Add a dependency to a function:
  `pnpm --filter @functions/auth add <package>`
- Link shared code in a function:
  `pnpm --filter @functions/auth add @shared/ts@workspace:*`
- Build a specific function:
  `turbo run build --filter=./functions/auth`

## Code Style & Conventions

- TypeScript strict mode enforced (see `tsconfig.base.json`).
- Use single quotes, no semicolons.
- Prefer functional programming patterns.
- Use ES2022+ features and ESNext modules.
- All code should pass ESLint and TypeScript checks before merging.

## Testing Instructions

- Run all tests: `pnpm test`
- Run tests for a specific package/function:
  `pnpm turbo run test --filter <project_name>`
- Lint all code: `pnpm lint`
- Typecheck all code: `pnpm typecheck`
- After moving files or changing imports, run `pnpm lint --filter <project_name>`.
- Add or update tests for any code you change.

## PR Instructions

- PR title format: `[<project_name>] <Title>`
- Always run `pnpm lint` and `pnpm test` before committing and merging.
- Commits should pass all checks and tests.

## Monorepo Tips

- Use `pnpm dlx turbo run where <project_name>` to locate packages/functions.
- Check the `name` field in each package's `package.json` for correct workspace references.
- Use nested AGENTS.md files in subprojects for tailored agent instructions.

## About

AGENTS.md is an open format for guiding coding agents, used by many open-source projects. For more, see [agents.md](https://agents.md/).

## FAQ

### Are there required fields?

No. Use any headings; agents parse the text you provide.

### What if instructions conflict?

The closest AGENTS.md to the edited file wins; explicit user chat prompts override everything.

### Will the agent run testing commands found in AGENTS.md automatically?

Yes—if you list them. The agent will attempt to execute relevant programmatic checks and fix failures before finishing the task.

### Can I update it later?

Absolutely. Treat AGENTS.md as living documentation.

### How do I migrate existing docs to AGENTS.md?

Rename existing files to AGENTS.md and create symbolic links for backward compatibility:

        mv AGENT.md AGENTS.md && ln -s AGENTS.md AGENT.md

### How do I configure Aider?

Configure Aider to use AGENTS.md in `.aider.conf.yml`:

        read: AGENTS.md

### How do I configure Gemini CLI?

Configure Gemini CLI to use AGENTS.md in `.gemini/settings.json`:

        { "contextFileName": "AGENTS.md" }

---

AGENTS.md is an open-source community project.
