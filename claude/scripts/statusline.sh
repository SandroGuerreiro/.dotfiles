#!/usr/bin/env bash
# Claude Code status line: PR | 5h | model
# Input: JSON on stdin from Claude Code
# See: https://code.claude.com/docs/en/statusline.md

set -u

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# PR number for current branch, cached per branch for 5 min to avoid network on every render.
pr=""
if [ -n "$cwd" ] && cd "$cwd" 2>/dev/null; then
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    if [ -n "$branch" ] && [ "$branch" != "HEAD" ]; then
        repo_hash=$(echo -n "$cwd" | shasum | cut -c1-8)
        cache_file="/tmp/claude-statusline-pr-${repo_hash}-${branch//\//_}"
        if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0))) -lt 300 ]; then
            pr=$(cat "$cache_file" 2>/dev/null)
        else
            pr=$(gh pr view --json number -q .number 2>/dev/null || true)
            echo "$pr" > "$cache_file" 2>/dev/null || true
        fi
    fi
fi

# Colors
B='\033[38;2;30;102;245m'    # blue
G='\033[38;2;64;160;43m'     # green
M='\033[38;2;136;57;239m'    # magenta
T='\033[38;2;76;79;105m'     # gray
R='\033[0m'
SEP=" ${T}|${R} "

parts=()
[ -n "$pr" ]     && parts+=("${G}PR #${pr}${R}")
[ -n "$five_h" ] && parts+=("${M}5h: $(printf '%.0f' "$five_h")%${R}")
[ -n "$model" ]  && parts+=("${B}${model}${R}")

out=""
for p in "${parts[@]}"; do
    [ -n "$out" ] && out="${out}${SEP}"
    out="${out}${p}"
done
printf "%b\n" "$out"
