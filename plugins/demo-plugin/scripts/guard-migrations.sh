#!/usr/bin/env bash
# PreToolUse hook: block edits to Flyway migrations that are already committed to git.
# Exit 0 = allow, exit 2 = block (stderr is shown to Claude), other codes = non-blocking error.
set -uo pipefail

# At runtime, Claude Code pipes a JSON description of the pending call to the
# script's stdin: the tool name, tool_input (including file_path), the session
# and the working directory. The exit code decides the outcome:
input=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  echo "guard-migrations: jq not found, migration guard is DISABLED" >&2
  exit 1   # fail open: warn, but don't block. A deliberate trade-off worth discussing.
fi

file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file" ] && exit 0

case "$file" in
  */db/migration/V*.sql) ;;
  *) exit 0 ;;
esac

dir=$(dirname "$file")
name=$(basename "$file")
[ -d "$dir" ] || exit 0

if [ -n "$(git -C "$dir" log -1 --format=%H -- "$name" 2>/dev/null)" ]; then
  cat >&2 <<MSG
BLOCKED by demo-plugin: $name is an applied Flyway migration (already committed).
Applied migrations must never be edited. Create a new migration instead.
MSG
  exit 2
fi

exit 0
