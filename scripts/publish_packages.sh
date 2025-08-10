#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

echo "📦 Melos Bootstrap & Publish Script"

echo "🔁 Bootstrapping..."
melos bootstrap
echo "✅ Bootstrap complete"

if [[ "${RUN_TESTS:-false}" == "true" ]]; then
  echo "🧪 Running tests..."
  melos run test || { echo "❌ Tests failed"; exit 1; }
fi

echo "🧼 Formatting..."
melos run format || echo "⚠️ Formatting failed, continuing..."

echo "📌 Committing pre-version changes..."
if [[ -n "$(git status --porcelain)" ]]; then
  git add .
  git commit -m "chore: prepare for version bump"
fi

echo "🔢 Detecting changes & bumping versions..."
melos version --yes  # <-- no --all, only changed packages + dependents
echo "✅ Version bump complete"

#echo "📌 Pushing commits & tags..."
#git push --follow-tags

echo "🔍 Dry-run publish..."
melos publish --dry-run
echo "✅ Dry run complete"

#echo "🚀 Publishing..."
#melos publish --no-dry-run --yes
echo "🎯 All changed packages published!"
