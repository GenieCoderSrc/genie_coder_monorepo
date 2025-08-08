#!/bin/bash
set -e

# Go to repo root
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "💾 Committing version changes..."
git add .

echo "⏳ Fetching latest origin/main..."
git fetch origin main

echo "🔍 Detecting changed packages compared to origin/main..."
CHANGED_PACKAGES=$(melos list --diff=origin/main --json | jq -r '.[].location')

if [ -z "$CHANGED_PACKAGES" ]; then
  echo "✅ No changed packages detected."
  exit 0
fi

echo "📦 Changed packages:"
echo "$CHANGED_PACKAGES" | sed 's/^/ - /'
echo

for PKG_DIR in $CHANGED_PACKAGES; do
    PKG_NAME=$(basename "$PKG_DIR")
    echo "🔹 Processing package: $PKG_NAME"

    echo "Select commit type:"
    select TYPE in feat fix chore docs style refactor perf test; do
        if [[ -n "$TYPE" ]]; then
            break
        fi
    done

    read -p "📝 Enter commit description: " DESC

    COMMIT_MSG="$TYPE($PKG_NAME): $DESC"

    # Stage package files by folder path
    git add "$PKG_DIR"

    # Skip commit if no staged changes
    if git diff --cached --quiet; then
        echo "⚠️ No staged changes for $PKG_NAME, skipping..."
        continue
    fi

    git commit -m "$COMMIT_MSG"
    git push

    echo "✅ Committed & pushed: $COMMIT_MSG"
    echo
done

echo "🎯 All changed packages have been committed and pushed."
