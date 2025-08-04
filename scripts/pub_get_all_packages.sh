#!/bin/bash

# Exit on script-level error (not individual subshells)
set -e

# Go to repo root
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

PACKAGES_DIR="$ROOT_DIR/packages"

echo "📦 Running 'flutter pub get' for each package in $PACKAGES_DIR"

# Check if packages directory exists
if [ ! -d "$PACKAGES_DIR" ]; then
  echo "❌ packages directory not found at: $PACKAGES_DIR"
  exit 1
fi

# Loop through each subdirectory in the packages directory
for dir in "$PACKAGES_DIR"/*/; do
  if [ -f "$dir/pubspec.yaml" ]; then
    echo "➡️ Running 'flutter pub get' in: $dir"
    (
      cd "$dir"
      if flutter pub get; then
        echo "✅ Success in $dir"
      else
        echo "⚠️ Error in $dir — skipping due to pubspec.yaml issue"
      fi
    )
  else
    echo "⏭️ Skipping $dir (no pubspec.yaml found)"
  fi
done

echo "🏁 Finished processing all packages."
