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

# 3. Version bump
echo "🔢 Running melos version (auto version bump)..."
melos version --yes
echo "✅ Version bump complete"
echo

# 4. Formatting
echo "🧼 Formatting packages..."
melos run format || echo "⚠️ Format failed, continuing..."
echo "✅ Formatting done"
echo

# 5. Commit and push changes
echo "📌 Committing version bump and publishing..."
if [[ -n "$(git status --porcelain)" ]]; then
  git add .
  git commit -m "🔖 chore: version bump and publish packages"
  git push
  git push --tags
  echo "✅ Changes pushed to GitHub with tags"
else
  echo "ℹ️ No changes to commit."
fi


# 6. Dry run publish
echo "🔍 Running dry run publish..."
melos publish --dry-run

# 7. Publish
echo "🚀 Publishing to pub.dev..."
melos publish --yes


echo "🎯 All packages published successfully!"
