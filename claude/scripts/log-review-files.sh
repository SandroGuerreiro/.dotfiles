#!/bin/bash
# Logs files mentioned in code reviews that have CRITICAL or HIGH severity issues
# Triggered via PostToolUse hook on the Agent tool

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
[ "$TOOL_NAME" = "Agent" ] || exit 0

CLAUDE_SESSION=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
[ -n "$CLAUDE_SESSION" ] || exit 0

OUTPUT=$(echo "$INPUT" | jq -r '
  if (.tool_response | type) == "string" then .tool_response
  elif (.tool_response.content | type) == "string" then .tool_response.content
  elif (.tool_response.output | type) == "string" then .tool_response.output
  else "" end' 2>/dev/null)

[ -n "$OUTPUT" ] || exit 0

echo "$OUTPUT" | grep -qiE '\b(CRITICAL|HIGH|MEDIUM|LOW|BLOCK|WARN|APPROVE|code review)\b' || exit 0

LOGFILE="/tmp/claude-review-files-${CLAUDE_SESSION}.log"

echo "$OUTPUT" | \
  grep -oE '[a-zA-Z0-9_./-]+\.(ts|tsx|js|jsx|py|rs|go|lua|sh|json|yaml|yml|toml)' | \
  while read -r FILE; do
    CLEAN="${FILE%%:*}"
    [ -f "$CLEAN" ] && echo "$CLEAN" >> "$LOGFILE"
  done

[ -f "$LOGFILE" ] && sort -u -o "$LOGFILE" "$LOGFILE"
exit 0
