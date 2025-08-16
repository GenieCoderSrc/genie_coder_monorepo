#!/bin/bash
# File: scripts/convert_subtrees.sh
# Purpose: Convert all subtree packages showing "modified content" into normal folders and commit them

set -e  # Exit immediately if a command fails

# Move to the root of the repo
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || { echo "Failed to change directory to root"; exit 1; }

echo "Starting conversion of subtrees to normal folders..."

for pkg in packages/*; do
  if [ -d "$pkg" ]; then
    # Check if Git thinks this folder is a submodule
    if [ -d ".git/modules/$pkg" ]; then
      echo "Removing submodule metadata for $pkg"
      rm -rf ".git/modules/$pkg"
    fi

    # Remove submodule index reference (if exists)
    if git ls-files --stage "$pkg" | grep -q ^160000; then
      echo "Removing cached submodule reference for $pkg"
      git rm --cached "$pkg"
    fi

    # Add folder back as normal tracked files
    echo "Adding $pkg as normal folder"
    git add "$pkg"
  fi
done

# Commit all changes
echo "Committing changes..."
git commit -m "Convert all subtree packages to normal folders"

echo "Conversion complete!"
