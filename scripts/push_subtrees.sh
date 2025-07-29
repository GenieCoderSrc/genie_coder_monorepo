#!/bin/bash

set -e

echo "🚀 Pushing package subtrees to their remotes..."

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

PACKAGES_DIR="packages"

for dir in "$PACKAGES_DIR"/*/; do
  pkg_name=$(basename "$dir")
  remote_name="subtree-$pkg_name"

  if git remote | grep -q "^$remote_name$"; then
    echo "📦 Pushing subtree for $pkg_name → $remote_name..."
    git subtree push --prefix="$PACKAGES_DIR/$pkg_name" "$remote_name" main
  else
    echo "⚠️ Remote '$remote_name' not found. Skipping $pkg_name."
  fi
done