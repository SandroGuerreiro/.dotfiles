#!/bin/bash
# Logs files mentioned in code reviews that have CRITICAL or HIGH severity issues
# Triggered via PostToolUse hook on the Agent tool

INPUT=$(cat)

# Only process Agent tool calls
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
[ "$TOOL_NAME" = "Agent" ] || exit 0

# Extract text output — try multiple possible response shapes
OUTPUT=$(echo "$INPUT" | jq -r '
  if (.tool_response | type) == "string" then .tool_response
  elif (.tool_response.content | type) == "string" then .tool_response.content
  elif (.tool_response.output | type) == "string" then .tool_response.output
  else "" end' 2>/dev/null)

[ -n "$OUTPUT" ] || exit 0

# Only process if this looks like a code review output
echo "$OUTPUT" | grep -qiE '\b(CRITICAL|HIGH|MEDIUM|LOW|BLOCK|WARN|APPROVE|code review)\b' || exit 0

if [ -n "$TMUX" ]; then
  SESSION_ID=$(tmux display-message -p '#{session_name}:#{window_index}' 2>/dev/null)
fi
SESSION_ID="${SESSION_ID:-$$}"
LOGFILE="/tmp/claude-review-files-${SESSION_ID}.log"

# Extract all file paths from the review output and log those that exist on disk
echo "$OUTPUT" | \
  grep -oE '[a-zA-Z0-9_./-]+\.(ts|tsx|js|jsx|py|rs|go|lua|sh|json|yaml|yml|toml)' | \
  while read -r FILE; do
    CLEAN="${FILE%%:*}"
    [ -f "$CLEAN" ] && echo "$CLEAN" >> "$LOGFILE"
  done

[ -f "$LOGFILE" ] && sort -u -o "$LOGFILE" "$LOGFILE"
exit 0
