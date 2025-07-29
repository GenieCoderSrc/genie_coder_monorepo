#!/bin/bash

set -e

echo "⬇️ Pulling subtrees from their remotes..."

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

PACKAGES_DIR="packages"

for dir in "$PACKAGES_DIR"/*/; do
  pkg_name=$(basename "$dir")
  remote_name="subtree-$pkg_name"

  if git remote | grep -q "^$remote_name$"; then
    echo "📥 Pulling subtree for $pkg_name from $remote_name..."
    git subtree pull --prefix="$PACKAGES_DIR/$pkg_name" "$remote_name" main --squash
  else
    echo "⚠️ Remote '$remote_name' not found. Skipping $pkg_name."
  fi
done