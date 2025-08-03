#!/bin/bash

set -e

# ────────────────────────────────────────────────────────────────
# 🌐 CONFIGURATION
# ────────────────────────────────────────────────────────────────


# Constants
BASE_DIR="packages"
BASE_REMOTE_URL="https://github.com/GenieCoderSrc"
DEFAULT_BRANCH="main" # fallback if no other branch is provided
PUSH_AFTER_PULL=true

echo "📦 Scanning packages in $PACKAGES_PATH..."

# ────────────────────────────────────────────────────────────────
# 🧠 HELPERS
# ────────────────────────────────────────────────────────────────

commit_local_changes_if_any() {
  if ! git diff-index --quiet HEAD --; then
    echo "💾 Committing local changes..."
    git add .
    git commit -m "chore: auto-commit uncommitted changes before syncing subtree"
  fi
}

subtree_exists() {
  git log -- "$1" > /dev/null 2>&1
}

# ────────────────────────────────────────────────────────────────
# 🚀 START SCRIPT
# ────────────────────────────────────────────────────────────────

echo "🧪 Starting monorepo sync..."

for repo in "$BASE_DIR"/*; do
  echo "───────────────────────────────────────────────────────"
  echo "🔄 Processing $repo ..."

  PACKAGE_PATH="$BASE_DIR/$repo"

  # If a specific branch exists locally, use it
  BRANCH=$(git ls-remote --heads "$BASE_REMOTE_URL/$repo.git" | grep "refs/heads/$(whoami)" | awk '{print $2}' | sed 's@refs/heads/@@')

  # If no personal branch exists, fallback to main
  if [ -z "$BRANCH" ]; then
    BRANCH="$DEFAULT_BRANCH"
  fi

  REMOTE_NAME="$repo"

  # Add remote if not already added
  if ! git remote | grep -q "^$REMOTE_NAME$"; then
    echo "➕ Adding remote $REMOTE_NAME..."
    git remote add "$REMOTE_NAME" "$BASE_REMOTE_URL/$repo.git"
  fi

  echo "🌿 Using branch: $BRANCH"

  # Fetch latest
  git fetch "$REMOTE_NAME" "$BRANCH"

  # Commit uncommitted changes if any
  commit_local_changes_if_any

  # Add or pull subtree
  if subtree_exists "$PACKAGE_PATH"; then
    echo "📥 Pulling updates for existing subtree..."
    git subtree pull --prefix="$PACKAGE_PATH" "$REMOTE_NAME" "$BRANCH" --squash || echo "⚠️ Subtree pull failed for $repo"
  else
    echo "📦 Adding new subtree..."
    git subtree add --prefix="$PACKAGE_PATH" "$REMOTE_NAME" "$BRANCH" --squash || echo "⚠️ Subtree add failed for $repo"
  fi

  echo "✅ Done with $repo"
done

# ────────────────────────────────────────────────────────────────
# ⏫ PUSH CHANGES
# ────────────────────────────────────────────────────────────────

if [ "$PUSH_AFTER_PULL" = true ]; then
  echo "🚀 Pushing changes to origin..."
  git push origin "$(git rev-parse --abbrev-ref HEAD)"
fi

echo "🎉 All done!"
