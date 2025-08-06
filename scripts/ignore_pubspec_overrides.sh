#!/bin/bash


ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1


# Path to all submodules (adjust if needed)
SUBMODULE_DIRS=$(find packages -maxdepth 1 -mindepth 1 -type d)

for DIR in $SUBMODULE_DIRS; do
  echo "Processing $DIR..."

  GITIGNORE_FILE="$DIR/.gitignore"
  OVERRIDE_FILE="$DIR/pubspec_overrides.yaml"

  # 1. Append ignore rule if not already there
  if ! grep -Fxq "pubspec_overrides.yaml" "$GITIGNORE_FILE" 2>/dev/null; then
    echo "pubspec_overrides.yaml" >> "$GITIGNORE_FILE"
    echo "  ➤ Added to .gitignore"
  else
    echo "  ➤ Already in .gitignore"
  fi

  # 2. Check if pubspec_overrides.yaml is being tracked
  if git -C "$DIR" ls-files --error-unmatch pubspec_overrides.yaml > /dev/null 2>&1; then
    git -C "$DIR" rm --cached pubspec_overrides.yaml
    echo "  ➤ Removed from git index"
  fi

  # 3. Commit if changes exist
  if [ -n "$(git -C "$DIR" status --porcelain)" ]; then
    git -C "$DIR" add .gitignore
    git -C "$DIR" commit -m "Ignore pubspec_overrides.yaml"
    echo "  ➤ Committed in submodule"
  else
    echo "  ➤ No changes to commit"
  fi
done

# 4. Stage updated submodules in the main repo
echo "Staging updated submodules in main repo..."
git add packages/*
echo "Done. Now run:"
echo "  git commit -m \"Update submodules to ignore pubspec_overrides.yaml\""
