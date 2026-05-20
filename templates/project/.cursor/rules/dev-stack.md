# Dev Stack Rules

This project uses the dev-stack toolchain. See the [dev-stack repo](https://github.com/nkrishnan/dev-stack) for full documentation.

## Conventions

- Use `dev-stack init` to initialize new projects with standard templates.
- Keep secrets out of version control; use `.env.local` (git-excluded).
- Store opencode auth in `.opencode-auth.json` (git-excluded).
- Follow the stack change process documented in `docs/stack-change-process.md`.
