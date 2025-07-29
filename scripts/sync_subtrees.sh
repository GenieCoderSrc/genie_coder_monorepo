#!/bin/bash

set -e

echo "🔄 Committing & syncing all subtrees..."

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

echo "📝 Committing all changes..."
git add .
git commit -m "chore: sync all packages" || echo "⚠️ Nothing to commit."

echo "⬆️ Pushing subtrees..."
./scripts/push_subtrees.sh