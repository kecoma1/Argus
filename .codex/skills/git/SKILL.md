---
name: git
description: Use when creating git branches, commits, or GitHub issues in this repository. Enforces branch names in the form `feat/ticket-id__title`, commits in the form `feat(topic): summary` with `refs #ticket` on the next line, and issues with a fixed title/body structure.
---

# Git

Use this skill for branch names, commit messages, and issue creation in this repository.

## Branch Format

Use:

```text
feat/ticket-id__title
```

Rules:

- `feat` is the branch prefix for feature work.
- Use the ticket id after the first slash.
- Use a double underscore before the title.
- Keep `title` short, lowercase, and hyphenated.

Example:

```text
feat/123__add-login-validation
```

## Commit Format

Use:

```text
feat(topic): summary

refs #ticket
```

Rules:

- `topic` should match the main area changed.
- `summary` should be short, imperative, and lowercase.
- Put the ticket reference on its own line exactly as `refs #ticket`.

Example:

```text
feat(auth): add login validation

refs #123
```

## When To Apply

- Before creating a branch.
- Before writing or reviewing a commit message.

## Issue Format

Use issues with this structure:

- Title: short and specific
- Summary: maximum 7 words
- Objective: what the issue should achieve
- Plan: ordered implementation steps
- Details: constraints, examples, or notes

Keep the title aligned with the work scope and make the summary concise enough to scan quickly.
