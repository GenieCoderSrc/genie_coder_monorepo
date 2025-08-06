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
melos version --yes --all
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

  # Prevent accidental workflow push
  if git diff --cached --name-only | grep -q "^\.github/workflows/"; then
    echo "❌ Detected workflow file changes. These require PAT with 'workflow' scope."
    echo "   Either update your token or exclude workflow changes before pushing."
    exit 1
  fi

  git commit -m "🔖 chore: version bump and publish packages"

  git push
#  if [[ "${PUSH_TAGS:-true}" == "true" ]]; then
#    git push --tags
#  else
#    echo "🔖 Skipping tag push due to PUSH_TAGS=false"
#  fi
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
