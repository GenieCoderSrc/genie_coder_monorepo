#!/bin/bash


ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1


# Commit changes in all submodules
git submodule foreach '
  if [ -n "$(git status --porcelain)" ]; then
    echo "Committing changes in $name"
    git add .
    git commit -m "Auto-commit changes in $name"
  else
    echo "No changes in $name"
  fi
'

# Stage all submodule pointers in parent repo
git add $(git submodule | awk "{print \$2}")

# Commit the updated submodule pointers
git commit -m "Update all submodule pointers"
