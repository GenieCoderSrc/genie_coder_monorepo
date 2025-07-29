#!/bin/bash

set -e

echo "🔗 Adding subtree remotes for packages..."

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

GITHUB_ORG="GenieCoderSrc"
PACKAGES_DIR="packages"

for dir in "$PACKAGES_DIR"/*/; do
  pkg_name=$(basename "$dir")
  remote_name="subtree-$pkg_name"
  remote_url="git@github.com:$GITHUB_ORG/$pkg_name.git"

  if git remote | grep -q "^$remote_name$"; then
    echo "🔁 Remote '$remote_name' already exists."
  else
    git remote add "$remote_name" "$remote_url"
    echo "✅ Added remote $remote_name → $remote_url"
  fi
done