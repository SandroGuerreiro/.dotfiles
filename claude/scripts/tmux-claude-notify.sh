#!/bin/bash
# Sets/unsets a tmux window option used by window-status-format to show ⚡.
# Usage: tmux-claude-notify.sh stop|clear|clear-current
MODE="$1"

case "$MODE" in
  stop)
    [ -z "$TMUX_PANE" ] && exit 0
    WINDOW_ID=$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}' 2>/dev/null)
    [ -z "$WINDOW_ID" ] && exit 0
    tmux set-window-option -t "$WINDOW_ID" @claude_notify 1
    ;;

  clear)
    [ -z "$TMUX_PANE" ] && exit 0
    WINDOW_ID=$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}' 2>/dev/null)
    [ -z "$WINDOW_ID" ] && exit 0
    tmux set-window-option -ut "$WINDOW_ID" @claude_notify
    ;;

  clear-current)
    tmux set-window-option -u @claude_notify
    ;;
esac
