#!/usr/bin/env bash
# Recursively extract every .zip relative to the current working directory

set -euo pipefail

if ! command -v unzip >/dev/null 2>&1; then
  echo "Error: unzip is not installed." >&2
  exit 1
fi

BASE_DIR="$(pwd)"

find "$BASE_DIR" -type f -name '*.zip' -print0 | while IFS= read -r -d '' zip_file; do
  dir=$(dirname "$zip_file")
  echo "Extracting: $zip_file -> $dir"
  unzip -n -d "$dir" "$zip_file"
done
#!/usr/bin/env bash
# Recursively extract every .zip under the current working directory

set -euo pipefail

# Check that unzip is available
if ! command -v unzip >/dev/null 2>&1; then
  echo "Error: unzip is not installed." >&2
  exit 1
fi

# Search relative to the current working directory
BASE_DIR="$(pwd)"

find "$BASE_DIR" -type f -name '*.zip' -print0 | while IFS= read -r -d '' zip_file; do
  dir=$(dirname "$zip_file")
  echo "Extracting: $zip_file -> $dir"
  unzip -n -d "$dir" "$zip_file"
done
#!/usr/bin/env bash
# Recursively find .zip files under the current working directory and
# Create a directory next to each zip and extract the archive into it

set -euo pipefail

# Verify unzip
if ! command -v unzip >/dev/null 2>&1; then
  echo "Error: unzip is not installed." >&2
  exit 1
fi

BASE_DIR="$(pwd)"

find "$BASE_DIR" -type f -name '*.zip' -print0 | while IFS= read -r -d '' zip_file; do
  # Directory containing the zip
  parent_dir=$(dirname "$zip_file")

  # Zip filename without the extension
  zip_name=$(basename "$zip_file" .zip)

  # New extraction directory
  target_dir="$parent_dir/$zip_name"

  # Create the directory
  mkdir -p "$target_dir"

  echo "Extracting: $zip_file -> $target_dir"

  # Do not overwrite existing files (-n)
  unzip -n -d "$target_dir" "$zip_file"
done
