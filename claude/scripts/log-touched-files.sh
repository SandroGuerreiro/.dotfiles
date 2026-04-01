#!/bin/bash
# Logs files that Claude Code reads/edits/writes to a temp file
# Scoped per tmux window so each session has its own log
# Hook input is passed via stdin as JSON
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
if [ -n "$FILE" ] && [ -f "$FILE" ]; then
  # Use tmux window ID for session isolation, fall back to TTY
  if [ -n "$TMUX" ]; then
    SESSION_ID=$(tmux display-message -p '#{session_name}:#{window_index}' 2>/dev/null)
  fi
  SESSION_ID="${SESSION_ID:-$$}"
  LOGFILE="/tmp/claude-files-${SESSION_ID}.log"
  echo "$FILE" >> "$LOGFILE"
  # Deduplicate in place
  sort -u -o "$LOGFILE" "$LOGFILE"
fi
