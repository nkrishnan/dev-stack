# Spec Kit

[github/spec-kit](https://github.com/github/spec-kit) is a spec-driven development toolkit.
Write a spec first; the coding agent implements it.

## Installation

Installed automatically by `dev-stack install` via `uv tool install specify-cli`.
Requires `uv`, which is also installed by `dev-stack install`.

## Usage

```bash
# Initialise spec-kit in a project
specify init . --integration opencode   # or copilot, etc.

# Write a constitution (project principles)
/speckit.constitution Define principles for this project

# Write a spec for a feature
/speckit.specify Build a user authentication flow with email + password
```

Slash commands are available inside your coding agent (opencode, Copilot, etc.).

## Decisions log

Architectural decisions that predate spec-kit live in `docs/decisions/`.
