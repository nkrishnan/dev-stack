# Codespaces

This repo is designed to bootstrap itself as a GitHub Codespace via the dotfiles mechanism.

## How it works

GitHub Codespaces supports [dotfiles repositories](https://docs.github.com/en/codespaces/setting-your-codespace-to-use-dotfiles). When a Codespace is created, GitHub clones the dotfiles repo and runs the installer.

`install.sh` at the repo root is the canonical entrypoint. It sets `DEV_STACK_HOME` to the cloned repo directory and delegates to `bin/dev-stack install`, which symlinks the CLI into `~/.local/bin`.

## Bootstrap sequence

```
GitHub clones dotfiles repo → runs install.sh
  └─ sets DEV_STACK_HOME to the cloned repo path
  └─ bin/dev-stack install
       └─ creates ~/.local/bin/dev-stack → symlink to bin/dev-stack
```

## Expected behaviour in a fresh Codespace

GitHub dotfiles will have already run `install.sh` before the terminal is ready.
Verify the bootstrap completed, initialise the project, and start coding:

```bash
# 1. Confirm the CLI is on PATH (dotfiles ran install.sh automatically)
command -v dev-stack

# 2. Copy project templates into this repo and add local-only ignores
dev-stack init

# 3. Start the coding agent
opencode
```

## Self-test

Opening a Codespace for the `dev-stack` repo itself serves as a useful integration test of the bootstrap flow.

## PATH

`~/.local/bin` must be on `$PATH`. The install command will warn if it is not. Most base images include it; if not, add it to your shell profile:

```bash
export PATH="$HOME/.local/bin:$PATH"
```
