#!/bin/bash

set -e

# Ensure we're inside a Git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Error: This script must be run inside a Git repository."
  exit 1
fi

PACKAGES_PATH="packages"
ORG_URL="https://github.com/GenieCoderSrc"

echo "📦 Scanning packages in $PACKAGES_PATH..."

# Loop through each directory inside packages/
for dir in "$PACKAGES_PATH"/*/; do
  PACKAGE_NAME=$(basename "$dir")
  SUBFOLDER="$PACKAGES_PATH/$PACKAGE_NAME"
  REPO_URL="$ORG_URL/$PACKAGE_NAME.git"

  echo ""
  echo "🚀 Processing $PACKAGE_NAME into $SUBFOLDER ..."

  # Clean existing remote if already present
  if git remote | grep -q "^$PACKAGE_NAME$"; then
    echo "🔁 Removing existing remote $PACKAGE_NAME"
    git remote remove "$PACKAGE_NAME"
  fi

  git remote add "$PACKAGE_NAME" "$REPO_URL"

  # Fetch remote
  echo "📥 Fetching $REPO_URL ..."
  git fetch "$PACKAGE_NAME" || {
    echo "⚠️ Failed to fetch $PACKAGE_NAME from $REPO_URL"
    git remote remove "$PACKAGE_NAME"
    continue
  }

  # Pull or Add subtree
  if [ -d "$SUBFOLDER" ]; then
    echo "🔄 Updating existing package using subtree pull..."
    git subtree pull --prefix="$SUBFOLDER" "$PACKAGE_NAME" main --squash || {
      echo "⚠️ Subtree pull failed for $PACKAGE_NAME"
    }
  else
    echo "➕ Adding new package using subtree add..."
    git subtree add --prefix="$SUBFOLDER" "$PACKAGE_NAME" main --squash || {
      echo "⚠️ Subtree add failed for $PACKAGE_NAME"
    }
  fi

  # Remove remote to keep things clean
  git remote remove "$PACKAGE_NAME"

  echo "✅ Done with $PACKAGE_NAME"
done

echo ""
echo "🎉 All packages processed in $PACKAGES_PATH/"
