#!/bin/bash
set -euo pipefail

echo "🚀 Melos Release Script (Flutter Monorepo + Conventional Changelog)"
echo

# Go to repo root
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# 1️⃣ Ensure Melos is installed
if ! command -v melos &> /dev/null; then
  echo "❌ Melos not found. Installing..."
  dart pub global activate melos
fi

# 2️⃣ Bootstrap packages
echo "🔁 Bootstrapping..."
melos bootstrap
echo "✅ Bootstrap complete"
echo

# 3️⃣ Detect changed packages since last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [[ -n "$LAST_TAG" ]]; then
  CHANGED=$(melos list --diff "$LAST_TAG..HEAD" --no-private)
else
  echo "⚠️ No previous tag found. Considering all packages as changed."
  CHANGED="all"
fi

if [[ -z "$CHANGED" ]]; then
  echo "✅ No package changes detected. Exiting."
  exit 0
fi

# 4️⃣ Stash any workflow file changes (to avoid workflow scope block)
echo "🛡️  Temporarily stashing workflow file changes..."
git stash push -m "temp-workflow-changes" -- .github/workflows || true

# 5️⃣ Version bump + changelog
echo "📦 Generating versions & changelogs..."
melos version \
  --yes \
  --git-tag-version \
  --changelog \
  --message "chore(release): publish packages {new_package_versions}"

echo "✅ Versions & changelogs generated"
echo

# 6️⃣ Push changes + tags
echo "⬆️  Pushing commits & tags..."
git push origin HEAD
git push origin --follow-tags

# 7️⃣ Restore workflow changes (if any)
if git stash list | grep -q "temp-workflow-changes"; then
  echo "♻️  Restoring workflow file changes..."
  git stash pop || true
fi

echo
echo "🎉 Release complete!"
