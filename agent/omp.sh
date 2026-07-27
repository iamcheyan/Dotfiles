#!/usr/bin/env bash
# Usage:
#   omp                          # Launch omp (interactive)
#   omp -f                       # Force reinstall
#   omp <args...>                # Pass arguments through to omp

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"

FORCE_REINSTALL=false
for arg in "$@"; do
  if [ "$arg" = "-f" ]; then
    FORCE_REINSTALL=true
    break
  fi
done

if $FORCE_REINSTALL || ! command -v omp &>/dev/null; then
  echo "omp not found, installing..."
  curl -fsSL https://omp.sh/install | sh
  export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"
fi

exec omp "$@"
