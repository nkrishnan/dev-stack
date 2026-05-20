#!/usr/bin/env bats
# Tests for config file validity

STACK_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

@test "templates/llm-app/openrouter-models.json is valid JSON" {
  run python3 -c "import json,sys; json.load(open('$STACK_DIR/templates/llm-app/openrouter-models.json'))"
  [ "$status" -eq 0 ]
}

@test "llm-app template: has a non-empty models array" {
  run python3 -c "
import json, sys
data = json.load(open('$STACK_DIR/templates/llm-app/openrouter-models.json'))
assert isinstance(data.get('models'), list) and len(data['models']) > 0
"
  [ "$status" -eq 0 ]
}

@test "llm-app template: free models come before paid models" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/templates/llm-app/openrouter-models.json'))
models = data['models']
free = [i for i, m in enumerate(models) if ':free' in m]
paid = [i for i, m in enumerate(models) if ':free' not in m]
if free and paid:
    assert max(free) < min(paid), 'free models must appear before paid models'
"
  [ "$status" -eq 0 ]
}

@test "llm-app template: has allow_fallbacks set" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/templates/llm-app/openrouter-models.json'))
assert data.get('provider', {}).get('allow_fallbacks') is True
"
  [ "$status" -eq 0 ]
}

@test "llm-app template: has require_parameters set for tool use support" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/templates/llm-app/openrouter-models.json'))
assert data.get('provider', {}).get('require_parameters') is True
"
  [ "$status" -eq 0 ]
}

@test "llm-app template: uses throughput sort" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/templates/llm-app/openrouter-models.json'))
assert data.get('provider', {}).get('sort') == 'throughput'
"
  [ "$status" -eq 0 ]
}

@test "llm-app template: includes a strong reasoning model" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/templates/llm-app/openrouter-models.json'))
models = data['models']
assert any('deepseek-r1' in m for m in models), 'expected a deepseek-r1 variant'
"
  [ "$status" -eq 0 ]
}

@test "opencode configs include claude-opus for complex tasks" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/opencode/opencode.json'))
model_keys = list(data['provider']['openrouter']['models'].keys())
assert any('claude-opus' in k for k in model_keys)
"
  [ "$status" -eq 0 ]
}

@test "opencode configs include deepseek-r1 for reasoning tasks" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/opencode/opencode.json'))
model_keys = list(data['provider']['openrouter']['models'].keys())
assert any('deepseek-r1' in k for k in model_keys)
"
  [ "$status" -eq 0 ]
}

@test "opencode configs include qwen free model" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/opencode/opencode.json'))
assert '~qwen/qwen3-235b-a22b:free' in data['provider']['openrouter']['models']
"
  [ "$status" -eq 0 ]
}

@test "opencode configs include qwen paid model" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/opencode/opencode.json'))
assert '~qwen/qwen3-235b-a22b' in data['provider']['openrouter']['models']
"
  [ "$status" -eq 0 ]
}

@test "opencode configs include gemini-2.5-pro" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/opencode/opencode.json'))
model_keys = list(data['provider']['openrouter']['models'].keys())
assert any('gemini-2.5-pro' in k for k in model_keys)
"
  [ "$status" -eq 0 ]
}

@test "opencode configs include pareto-code router for automatic coding model selection" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/opencode/opencode.json'))
assert 'openrouter/pareto-code' in data['provider']['openrouter']['models']
"
  [ "$status" -eq 0 ]
}

@test "opencode configs include auto router for general automatic model selection" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/opencode/opencode.json'))
assert 'openrouter/auto' in data['provider']['openrouter']['models']
"
  [ "$status" -eq 0 ]
}

@test "llm-app template: includes gemma free model for provider diversity" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/templates/llm-app/openrouter-models.json'))
assert any('gemma' in m for m in data['models'])
"
  [ "$status" -eq 0 ]
}

@test "llm-app template: includes gemini-2.5-flash in cheap paid tier" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/templates/llm-app/openrouter-models.json'))
models = data['models']
flash_idx = next(i for i, m in enumerate(models) if 'gemini-2.5-flash' in m)
opus_idx  = next(i for i, m in enumerate(models) if 'opus' in m)
assert flash_idx < opus_idx, 'gemini-2.5-flash should appear before claude-opus'
"
  [ "$status" -eq 0 ]
}

@test "llm-app template: includes gemini-2.5-pro in premium tier" {
  run python3 -c "
import json
data = json.load(open('$STACK_DIR/templates/llm-app/openrouter-models.json'))
models = data['models']
free = [i for i, m in enumerate(models) if ':free' in m]
pro_idx = next(i for i, m in enumerate(models) if 'gemini-2.5-pro' in m)
assert pro_idx > max(free), 'gemini-2.5-pro must appear after free models'
"
  [ "$status" -eq 0 ]
}

@test "opencode/opencode.json is valid JSON" {
  run python3 -c "import json,sys; json.load(open('$STACK_DIR/opencode/opencode.json'))"
  [ "$status" -eq 0 ]
}

@test "templates/project/opencode.json is valid JSON" {
  run python3 -c "import json,sys; json.load(open('$STACK_DIR/templates/project/opencode.json'))"
  [ "$status" -eq 0 ]
}

@test "opencode/opencode.json and templates/project/opencode.json are identical" {
  run diff "$STACK_DIR/opencode/opencode.json" "$STACK_DIR/templates/project/opencode.json"
  [ "$status" -eq 0 ]
}
