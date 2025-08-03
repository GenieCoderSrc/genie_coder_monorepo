#!/bin/bash

# Go to repo root
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

# File to copy
SOURCE_FILE=".github/workflows/notify-mono.yml"

# Packages folder
PACKAGES_DIR="packages"

echo "📦 Copying $SOURCE_FILE to all packages that have pubspec.yaml ..."

# Check if the source file exists
if [ ! -f "$SOURCE_FILE" ]; then
  echo "❌ Source file '$SOURCE_FILE' not found!"
  exit 1
fi

# Loop through all packages containing pubspec.yaml
find "$PACKAGES_DIR" -type f -name "pubspec.yaml" | while read -r PUBSPEC_FILE; do
  PACKAGE_DIR=$(dirname "$PUBSPEC_FILE")
  TARGET_DIR="$PACKAGE_DIR/.github/workflows"

  # Create target workflows folder if missing
  mkdir -p "$TARGET_DIR"

  # Copy the file (will overwrite only this one file, not others)
  cp "$SOURCE_FILE" "$TARGET_DIR/"

  echo "✅ Copied to $TARGET_DIR"
done

echo "🎯 Done! notify-mono.yml copied to all packages without touching other workflow files."
