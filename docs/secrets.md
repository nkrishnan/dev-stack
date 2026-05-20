# Secrets Management

Never commit secrets to version control.

## Local secrets

Use `.env.local` for local environment variables. This file is added to `.git/info/exclude` by `dev-stack init` so it is ignored without modifying `.gitignore`.

## opencode auth

Store opencode authentication credentials in `.opencode-auth.json`. This file is also added to `.git/info/exclude` by `dev-stack init`.

## CI secrets

Store CI secrets in GitHub Actions secrets. Reference them in workflows via `${{ secrets.MY_SECRET }}`.

## Scanning

[gitleaks](https://github.com/gitleaks/gitleaks) is configured via `.gitleaks.toml` and runs as a pre-commit hook to prevent accidental secret commits.
