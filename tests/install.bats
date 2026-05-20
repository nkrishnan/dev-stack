#!/usr/bin/env bats
# Tests for install.sh (the Codespaces dotfiles entrypoint)

setup() {
  export ORIG_HOME="$HOME"
  export TEST_HOME
  TEST_HOME="$(mktemp -d)"
  export HOME="$TEST_HOME"

  export STACK_DIR
  STACK_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

  export DEV_STACK_SKIP_TOOLS=1
  export OPENROUTER_API_KEY=test-key
}

teardown() {
  export HOME="$ORIG_HOME"
  rm -rf "$TEST_HOME"
}

@test "install.sh exits 0" {
  run bash "$STACK_DIR/install.sh"
  [ "$status" -eq 0 ]
}

@test "install.sh creates the dev-stack symlink" {
  run bash "$STACK_DIR/install.sh"
  [ "$status" -eq 0 ]
  [ -L "$TEST_HOME/.local/bin/dev-stack" ]
}

@test "install.sh symlink is executable" {
  bash "$STACK_DIR/install.sh"
  [ -x "$TEST_HOME/.local/bin/dev-stack" ]
}
