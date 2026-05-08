#!/bin/bash
# Updates the per-window session pointer so nvim knows the current Claude session.
# Runs on UserPromptSubmit so the pointer is current even before any files are touched.
INPUT=$(cat)
CLAUDE_SESSION=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)

[ -n "$CLAUDE_SESSION" ] || exit 0

if [ -n "$TMUX_PANE" ]; then
  WINDOW_ID=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}:#{window_id}' 2>/dev/null)
fi
WINDOW_ID="${WINDOW_ID:-default}"
POINTER="/tmp/claude-current-session-${WINDOW_ID}"

[ "$(cat "$POINTER" 2>/dev/null)" = "$CLAUDE_SESSION" ] && exit 0

echo "$CLAUDE_SESSION" > "$POINTER"
