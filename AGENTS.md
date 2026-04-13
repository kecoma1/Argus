# Repository Guidelines

## Project Structure & Module Organization
This repository is currently an empty scaffold. When code is added, keep the top level minimal and predictable:

- `src/` for application source
- `tests/` or `__tests__/` for automated tests
- `docs/` for design notes and operational guidance
- `assets/` for static files such as images or fixtures

Prefer small, focused modules over large catch-all files. Name files by feature or responsibility, such as `src/auth/login.ts`.

## Build, Test, and Development Commands
No build or test scripts exist yet. When the project is initialized, document the exact commands in `package.json` or a `Makefile`. Typical examples:

- `npm install` installs dependencies
- `npm run dev` starts a local development server
- `npm test` runs the test suite
- `npm run build` produces a production build

Keep the README and this file aligned with the actual commands in use.

## Coding Style & Naming Conventions
Use the formatter and linter chosen for the stack, and keep style consistent across the codebase. Until then:

- Use 2 spaces for indentation in JavaScript, TypeScript, JSON, and Markdown code examples
- Prefer `camelCase` for variables and functions
- Use `PascalCase` for classes, React components, and type names
- Use `kebab-case` for filenames unless the framework requires otherwise

If formatting tools are added, commit their config files so the rules are explicit.

## Testing Guidelines
Add tests alongside implementation or in a mirrored test tree. Name test files after the unit under test, for example `login.test.ts` or `auth.spec.ts`. Prefer clear assertions over broad integration-only coverage. If a test runner is introduced, record how to run a single test file and the full suite.

## Commit & Pull Request Guidelines
There is no commit history yet, so no project-specific convention is established. Use short, imperative commit messages, such as `Add login validation`. For pull requests, include:

- A concise description of the change
- Linked issue or task number, if available
- Screenshots or logs for UI or behavior changes
- Notes on verification steps and known limitations

## Agent Notes
Before editing, inspect the current tree and avoid inventing tooling that the repository does not use. If you add a stack later, update this guide immediately so it stays accurate.
