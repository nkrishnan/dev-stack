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

@test "install: warns when BIN_DIR is not in PATH" {
  # Ensure BIN_DIR is definitely absent from PATH
  local stripped_path
  stripped_path="$(echo "$PATH" | tr ':' '\n' | grep -v "$BIN_DIR" | tr '\n' ':')"
  PATH="$stripped_path" run "$STACK_DIR/bin/dev-stack" install
  [ "$status" -eq 0 ]
  [[ "$output" == *"Add"*"to PATH"* ]]
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
  "$STACK_DIR/bin/dev-stack" init || true   # cp -n fails on second run; that's expected
  popd > /dev/null
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
