#!/usr/bin/env bash
# Usage:
#   cur                      # Run Cursor (default)
#   cur -f                   # Force reinstall Cursor
#   cur <args...>            # Pass arguments through to cursor
#
# ── Cursor CLI Reference ────────────────────────────────────────────────────────
#
# Run `cursor --help` for the full list of subcommands once installed.
#
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

# Check for -f flag (force reinstall)
FORCE_REINSTALL=false
for arg in "$@"; do
  if [ "$arg" = "-f" ]; then
    FORCE_REINSTALL=true
    break
  fi
done

if $FORCE_REINSTALL || ! command -v cursor-agent &>/dev/null; then
  echo "cursor not found, installing..."
  curl https://cursor.com/install -fsS | bash
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ $# -eq 0 ]; then
  exec cursor-agent
else
  exec cursor-agent "$@"
fi
