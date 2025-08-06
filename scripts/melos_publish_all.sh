#!/bin/bash

set -euo pipefail

# Go to repo root
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

echo "📦 Melos Bootstrap & Publish Script"

# 1. Bootstrap dependencies
echo "🔁 Running melos bootstrap..."
melos bootstrap
echo "✅ Bootstrap complete"
echo

# 2. (Optional) Run tests
if [[ "${RUN_TESTS:-false}" == "true" ]]; then
  echo "🧪 Running tests for all packages..."
  melos run test || { echo "⚠️ Some tests failed, aborting."; exit 1; }
  echo "✅ Tests passed"
fi

# 3. Format and lint
echo "🧼 Formatting packages..."
melos run format || echo "⚠️ Format failed, continuing..."
echo "✅ Formatting done"
echo

# 4. Commit changes
# This is a crucial step to provide melos version with a git history.
echo "📌 Committing changes before versioning..."
if [[ -n "$(git status --porcelain)" ]]; then
  git add .
  git commit -m "chore: prepare packages for publishing"
  echo "✅ Changes committed"
else
  echo "ℹ️ No changes to commit."
fi
echo

# 5. Version bump
# Melos will now use the new commit to determine the version bump.
echo "🔢 Running melos version (auto version bump)..."
# We add --no-push to prevent Melos from pushing tags before we're ready.
melos version --yes --all --no-push
echo "✅ Version bump complete"
echo

# 6. Commit and push the version bump
echo "📌 Committing version bump and pushing..."
if [[ -n "$(git status --porcelain)" ]]; then
  git add .
  git commit -m "🔖 chore: publish packages"
  git push
  git push --tags
  echo "✅ Changes pushed to GitHub with tags"
else
  echo "ℹ️ No version changes to commit."
fi

# 7. Dry run publish
echo "🔍 Running dry run publish..."
melos publish --dry-run
echo "✅ Dry run complete"
echo

# 8. Publish
echo "🚀 Publishing to pub.dev..."
melos publish --yes
echo "🎯 All packages published successfully!"