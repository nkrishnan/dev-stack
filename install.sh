#!/usr/bin/env bash
set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DEV_STACK_HOME="$STACK_DIR"

"$STACK_DIR/bin/dev-stack" install
