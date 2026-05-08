#!/bin/bash
# Logs files that Claude Code reads/edits/writes to a temp file
# Scoped per Claude session_id; a per-window pointer tracks the current session
# Hook input is passed via stdin as JSON
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
CLAUDE_SESSION=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)

[ -n "$FILE" ] && [ -f "$FILE" ] && [ -n "$CLAUDE_SESSION" ] || exit 0

LOGFILE="/tmp/claude-files-${CLAUDE_SESSION}.log"
echo "$FILE" >> "$LOGFILE"
# Deduplicate via temp file (in-place sort fails on some paths)
sort -u "$LOGFILE" > "${LOGFILE}.tmp" 2>/dev/null && mv "${LOGFILE}.tmp" "$LOGFILE" || true

# Update per-window pointer so nvim knows which session is current
if [ -n "$TMUX_PANE" ]; then
  WINDOW_ID=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}:#{window_id}' 2>/dev/null)
fi
WINDOW_ID="${WINDOW_ID:-default}"
echo "$CLAUDE_SESSION" > "/tmp/claude-current-session-${WINDOW_ID}"
