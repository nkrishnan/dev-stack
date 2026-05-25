#!/usr/bin/env bats
# Tests for bin/dev-stack

setup() {
  # Create a temporary home and stack dir for each test
  export ORIG_HOME="$HOME"
  export TEST_HOME
  TEST_HOME="$(mktemp -d)"
  export HOME="$TEST_HOME"

  export STACK_DIR
  STACK_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export DEV_STACK_HOME="$STACK_DIR"
  export BIN_DIR="$TEST_HOME/.local/bin"

  # Prevent install from making real network calls during tests
  export DEV_STACK_SKIP_TOOLS=1
  # Suppress the API key reminder in test output
  export OPENROUTER_API_KEY=test-key
}

teardown() {
  export HOME="$ORIG_HOME"
  rm -rf "$TEST_HOME"
}

# ── install ──────────────────────────────────────────────────────────────────

@test "install: creates ~/.local/bin if it does not exist" {
  run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
  [ -d "$BIN_DIR" ]
}

@test "install: creates symlink at ~/.local/bin/dev-stack" {
  run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
  [ -L "$BIN_DIR/dev-stack" ]
}

@test "install: symlink points to bin/dev-stack in STACK_DIR" {
  run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
  local target
  target="$(readlink "$BIN_DIR/dev-stack")"
  [ "$target" = "$STACK_DIR/bin/dev-stack" ]
}

@test "install: is idempotent (re-running does not fail)" {
  "$STACK_DIR/bin/dev-stack" install
  run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
  [ -L "$BIN_DIR/dev-stack" ]
}

@test "install: adds BIN_DIR to .bashrc when not in PATH" {
  touch "$TEST_HOME/.bashrc"
  run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
  grep -q '.local/bin' "$TEST_HOME/.bashrc"
}

@test "install: does not duplicate PATH entry in .bashrc" {
  touch "$TEST_HOME/.bashrc"
  run "$STACK_DIR/bin/dev-stack" install
  run "$STACK_DIR/bin/dev-stack" install
  [ "$(grep -c '.local/bin' "$TEST_HOME/.bashrc")" -eq 1 ]
}

@test "install: creates .bashrc with PATH entry when no profile exists" {
  # TEST_HOME has no shell profiles
  run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
  [ -f "$TEST_HOME/.bashrc" ]
  grep -q '.local/bin' "$TEST_HOME/.bashrc"
}

@test "install: adds BIN_DIR to .zshrc when present" {
  touch "$TEST_HOME/.zshrc"
  run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
  grep -q '.local/bin' "$TEST_HOME/.zshrc"
}

# Helper: create stub executables for all tools so _install_* functions
# complete without network calls, allowing us to verify _ensure_path_dir_on_path
# behaviour for ~/.opencode/bin without side effects.
_setup_stub_tools() {
  mkdir -p "$BIN_DIR"
  for cmd in opencode mise uv specify; do
    printf '#!/bin/sh\nexec true\n' > "$BIN_DIR/$cmd"
    chmod +x "$BIN_DIR/$cmd"
  done
  export PATH="$BIN_DIR:$PATH"
}

@test "install: adds opencode bin dir to .bashrc" {
  touch "$TEST_HOME/.bashrc"
  _setup_stub_tools
  unset DEV_STACK_SKIP_TOOLS
  run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
  grep -q '.opencode/bin' "$TEST_HOME/.bashrc"
}

@test "install: adds opencode bin dir to .zshrc when present" {
  touch "$TEST_HOME/.bashrc"
  touch "$TEST_HOME/.zshrc"
  _setup_stub_tools
  unset DEV_STACK_SKIP_TOOLS
  run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
  grep -q '.opencode/bin' "$TEST_HOME/.zshrc"
}

@test "install: does not duplicate opencode bin dir in .bashrc" {
  touch "$TEST_HOME/.bashrc"
  _setup_stub_tools
  unset DEV_STACK_SKIP_TOOLS
  run "$STACK_DIR/bin/dev-stack" install
  run "$STACK_DIR/bin/dev-stack" install
  [ "$(grep -c '.opencode/bin' "$TEST_HOME/.bashrc")" -eq 1 ]
}

@test "install: does not duplicate opencode bin dir in .zshrc" {
  touch "$TEST_HOME/.bashrc"
  touch "$TEST_HOME/.zshrc"
  _setup_stub_tools
  unset DEV_STACK_SKIP_TOOLS
  run "$STACK_DIR/bin/dev-stack" install
  run "$STACK_DIR/bin/dev-stack" install
  [ "$(grep -c '.opencode/bin' "$TEST_HOME/.zshrc")" -eq 1 ]
}

@test "install: reminds about OPENROUTER_API_KEY when unset" {
  unset OPENROUTER_API_KEY
  run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
  [[ "$output" == *"OPENROUTER_API_KEY"* ]]
}

@test "install: no API key reminder when OPENROUTER_API_KEY is set" {
  OPENROUTER_API_KEY=test-key run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
  [[ "$output" != *"OPENROUTER_API_KEY"* ]]
}

@test "install: DEV_STACK_SKIP_TOOLS=1 suppresses tool installation" {
  # Verify install completes without attempting network calls by
  # shadowing curl with a function that fails if called
  curl() { echo "curl called unexpectedly"; return 1; }
  export -f curl
  DEV_STACK_SKIP_TOOLS=1 run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
}

# ── init ─────────────────────────────────────────────────────────────────────

setup_git_repo() {
  export PROJECT_DIR
  PROJECT_DIR="$(mktemp -d)"
  git -C "$PROJECT_DIR" init --quiet
  mkdir -p "$PROJECT_DIR/.git/info"
}

teardown_git_repo() {
  rm -rf "$PROJECT_DIR"
}

@test "init: copies opencode.json into the project directory" {
  setup_git_repo
  pushd "$PROJECT_DIR" > /dev/null
  run "$STACK_DIR/bin/dev-stack" init
  popd > /dev/null
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/opencode.json" ]
  teardown_git_repo
}

@test "init: copied opencode.json matches template" {
  setup_git_repo
  pushd "$PROJECT_DIR" > /dev/null
  "$STACK_DIR/bin/dev-stack" init
  popd > /dev/null
  diff "$STACK_DIR/templates/project/opencode.json" "$PROJECT_DIR/opencode.json"
  teardown_git_repo
}

@test "init: finds templates via installed symlink when DEV_STACK_HOME is unset" {
  setup_git_repo
  run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
  unset DEV_STACK_HOME
  pushd "$PROJECT_DIR" > /dev/null
  run "$BIN_DIR/dev-stack" init
  popd > /dev/null
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/opencode.json" ]
  teardown_git_repo
}

@test "init: copies cursor rules into .cursor/rules/" {
  setup_git_repo
  pushd "$PROJECT_DIR" > /dev/null
  run "$STACK_DIR/bin/dev-stack" init
  popd > /dev/null
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/.cursor/rules/dev-stack.md" ]
  teardown_git_repo
}

@test "init: adds .env.local to .git/info/exclude" {
  setup_git_repo
  pushd "$PROJECT_DIR" > /dev/null
  "$STACK_DIR/bin/dev-stack" init
  popd > /dev/null
  grep -qxF ".env.local" "$PROJECT_DIR/.git/info/exclude"
  teardown_git_repo
}

@test "init: adds .opencode-auth.json to .git/info/exclude" {
  setup_git_repo
  pushd "$PROJECT_DIR" > /dev/null
  "$STACK_DIR/bin/dev-stack" init
  popd > /dev/null
  grep -qxF ".opencode-auth.json" "$PROJECT_DIR/.git/info/exclude"
  teardown_git_repo
}

@test "init: does not duplicate .env.local in exclude on second run" {
  setup_git_repo
  pushd "$PROJECT_DIR" > /dev/null
  "$STACK_DIR/bin/dev-stack" init
  run "$STACK_DIR/bin/dev-stack" init
  popd > /dev/null
  [ "$status" -eq 0 ]
  local count
  count="$(grep -cxF ".env.local" "$PROJECT_DIR/.git/info/exclude")"
  [ "$count" -eq 1 ]
  teardown_git_repo
}

@test "init: prints 'Dev stack initialized.'" {
  setup_git_repo
  pushd "$PROJECT_DIR" > /dev/null
  run "$STACK_DIR/bin/dev-stack" init
  popd > /dev/null
  [[ "$output" == *"Dev stack initialized."* ]]
  teardown_git_repo
}

# ── usage ─────────────────────────────────────────────────────────────────────

@test "unknown subcommand exits with status 1" {
  run "$STACK_DIR/bin/dev-stack" unknown-command
  [ "$status" -eq 1 ]
}

@test "no arguments exits with status 1 and prints usage" {
  run "$STACK_DIR/bin/dev-stack"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}
