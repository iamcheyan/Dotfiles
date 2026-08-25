#!/bin/bash

# Iterate over all zip files in the current directory
for f in *.zip; do
  # Avoid errors when no zip files match
  [ -e "$f" ] || continue

  # Use the name without the .zip suffix as the directory name
  dir="${f%.zip}"

  # Create the directory if it does not exist
  mkdir -p "$dir"

  # Extract into the corresponding directory (-n means do not overwrite existing files)
  unzip -n "$f" -d "$dir"

  echo "Extracted: $f -> $dir/"
done

echo "Extraction complete"
