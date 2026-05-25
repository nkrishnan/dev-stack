# dev-stack

Opinionated bootstrap for a development environment and project defaults.

## What it does

- Installs and links the `dev-stack` CLI into `~/.local/bin`.
- Optionally installs core tooling (`opencode`, `mise`, `uv`, `specify-cli`).
- Initializes a project with shared config (`opencode.json`, Cursor rules, git excludes).

## Quick start

Run from this repository:

```bash
./install.sh
```

Or call the CLI directly:

```bash
./bin/dev-stack install
./bin/dev-stack init
./bin/dev-stack bootstrap
```

## Commands

- `dev-stack install`: installs the CLI symlink and tooling.
- `dev-stack init`: copies project templates into the current git repository.
- `dev-stack bootstrap`: installs the CLI/tooling, then initializes the current git repository.

## Notes

- Set `OPENROUTER_API_KEY` in your shell or Codespaces secrets.
- Set `DEV_STACK_SKIP_TOOLS=1` to skip networked tool installation.
