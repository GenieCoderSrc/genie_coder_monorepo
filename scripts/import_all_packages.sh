#!/bin/bash

set -e

# Constants
PACKAGES_PATH="packages"
ORG_URL="https://github.com/GenieCoderSrc"

echo "📦 Scanning packages in $PACKAGES_PATH..."

# Track if any changes were made
changes_made=false

# Loop through each directory or expected repo name
for dir in "$PACKAGES_PATH"/*; do
  [ -d "$dir" ] || continue
  PACKAGE_NAME=$(basename "$dir")
  SUBFOLDER="$PACKAGES_PATH/$PACKAGE_NAME"
  REPO_URL="$ORG_URL/$PACKAGE_NAME.git"

  echo ""
  echo "🚀 Processing $PACKAGE_NAME ..."

  # Check for uncommitted changes
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "💾 Uncommitted changes detected. Committing..."
    git add .
    git commit -m "chore: auto-commit before importing $PACKAGE_NAME"
    changes_made=true
  fi

  # Add and fetch from remote
  git remote add "$PACKAGE_NAME" "$REPO_URL" 2> /dev/null || true
  git fetch "$PACKAGE_NAME"

  # Get list of branches
  branches=$(git ls-remote --heads "$REPO_URL" | awk '{print $2}' | sed 's/refs\/heads\///')

  for branch in $branches; do
    echo "🌿 Importing branch '$branch' of $PACKAGE_NAME..."

    if [ -d "$SUBFOLDER" ]; then
      echo "🔄 Pulling updates into $SUBFOLDER ..."
      if git subtree pull --prefix="$SUBFOLDER" "$PACKAGE_NAME" "$branch" --squash; then
        echo "✅ Pulled $PACKAGE_NAME/$branch"
        changes_made=true
      else
        echo "⚠️ Subtree pull failed for $PACKAGE_NAME/$branch"
      fi
    else
      echo "➕ Adding new subtree $PACKAGE_NAME/$branch ..."
      if git subtree add --prefix="$SUBFOLDER" "$PACKAGE_NAME" "$branch" --squash; then
        echo "✅ Added $PACKAGE_NAME/$branch"
        changes_made=true
      else
        echo "⚠️ Subtree add failed for $PACKAGE_NAME/$branch"
      fi
    fi
  done

  git remote remove "$PACKAGE_NAME" || true
done

# Push if changes were made
if [ "$changes_made" = true ]; then
  echo ""
  echo "🚀 Pushing changes to origin..."
  git push origin "$(git rev-parse --abbrev-ref HEAD)"
  echo "✅ All changes pushed"
else
  echo ""
  echo "ℹ️ No changes to push."
fi

echo ""
echo "🎉 All packages processed successfully!"
