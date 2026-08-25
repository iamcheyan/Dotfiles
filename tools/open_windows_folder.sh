#!/usr/bin/env bash
# Open a folder in Windows Explorer from WSL

set -eo pipefail

# Validate arguments
if [[ $# -eq 0 ]]; then
  # Convert the current directory to a Windows path when no argument is given
  folder_path=$(wslpath -w "$PWD")
else
  # Join all arguments with spaces and treat them as one path.
  # Unquoted invocation may pass a path as multiple arguments.
  IFS=' '
  folder_path="$*"
fi

# Open the folder with explorer.exe
echo "Opening folder: ${folder_path}"
explorer.exe "${folder_path}"

