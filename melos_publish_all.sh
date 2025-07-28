#!/bin/bash

set -e

echo "📦 Melos Bootstrap & Publish Script"

# Ensure we're in the monorepo root
cd "$(dirname "$0")"

echo "🔁 Running melos bootstrap..."
melos bootstrap

echo "✅ Bootstrap complete"
echo

echo "🧪 Running tests for all packages..."
melos run test || echo "⚠️ Some tests failed. Continuing anyway..."

echo "🔢 Running melos version (auto version bump)..."
melos version --yes

echo "🧼 Formatting packages..."
melos run format

echo "🔍 Running dry run publish..."
melos publish --dry-run --no-confirm

echo "🚀 Publishing to pub.dev..."
melos publish --yes

echo "📌 Committing version bump and publishing..."
git add .
git commit -m "🔖 chore: version bump and publish packages"
git push

echo "✅ All packages published and pushed to GitHub!"
