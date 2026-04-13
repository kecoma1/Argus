---
name: create-pr
description: Use when writing pull requests for this repository. Enforces PR titles in the form `ticket-number | Título` and a body that always includes changes plus `Closes #ticket`.
---

# Create PR

Use this skill when creating a pull request in this repository.

## Title Format

Use:

```text
123 | Título
```

Rules:

- Start with the ticket number.
- Use ` | ` between the ticket and the title.
- Keep the title short and specific.

## Body Format

Every PR body must include these sections:

```md
# Cambios

Describe what changed and why.

# Detalles

List the main files or areas touched and any important notes.
```

## Required Close

The PR body must always end with:

```text
Closes #123
```

Rules:

- Always include the ticket number.
- Do not omit the closing line.
- Use the same ticket number as the PR title.

## Merge Strategy

Always use **squash and merge**. Never merge with a regular merge commit or rebase.

## Writing Rules

- Write in Spanish unless the user asks otherwise.
- Keep paragraphs short.
- Make the body explain intent, not only the diff.
