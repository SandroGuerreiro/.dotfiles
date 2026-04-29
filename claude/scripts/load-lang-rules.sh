#!/bin/bash
# Injects language-specific rules as additionalContext based on project type.
# Runs at SessionStart so rules are scoped to the session's working directory.

RULES_DIR="$HOME/.claude/rules"
context=""

if [ -f "Cargo.toml" ]; then
  for f in "$RULES_DIR/rust"/*.md; do
    [ -f "$f" ] && context+=$'\n\n'"$(cat "$f")"
  done
fi

if [ -f "tsconfig.json" ] || [ -f "package.json" ]; then
  for f in "$RULES_DIR/typescript"/*.md; do
    [ -f "$f" ] && context+=$'\n\n'"$(cat "$f")"
  done
fi

[ -z "$context" ] && exit 0

python3 -c "
import json, sys
context = sys.stdin.read()
print(json.dumps({
  'hookSpecificOutput': {
    'hookEventName': 'SessionStart',
    'additionalContext': context.strip()
  }
}))
" <<< "$context"
