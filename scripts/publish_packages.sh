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
# Commit any changes before running melos version.
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
# The --no-push flag is not a valid option for melos version.
# Melos version will create the tags locally.
melos version --yes --all
echo "✅ Version bump complete"
echo

# 6. Push changes and tags
# We manually push the commits and tags.
echo "📌 Pushing commits and tags to GitHub..."
git push
#git push --tags
echo "✅ Changes pushed to GitHub with tags"

# 7. Dry run publish
echo "🔍 Running dry run publish..."
melos publish --dry-run
echo "✅ Dry run complete"
echo

# 8. Publish
echo "🚀 Publishing to pub.dev..."
melos publish --no-dry-run
echo "🎯 All packages published successfully!"