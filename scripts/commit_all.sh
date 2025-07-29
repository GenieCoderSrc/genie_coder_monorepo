#!/bin/bash
echo "📝 Committing all subtree package changes..."

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

#Stage all changes (including untracked files and folders)
git add .

#Check if there's anything to commit
if git diff --cached --quiet; then
echo "✅ No changes to commit."
else
COMMIT_MSG="🔄 chore: commit all subtree package updates on $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$COMMIT_MSG"
echo "✅ Committed changes: $COMMIT_MSG"
fi


#!/bin/bash
#set -e
#
## Navigate to monorepo root
#SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#REPO_ROOT="$( dirname "$SCRIPT_DIR" )"
#cd "$REPO_ROOT"
#
#echo "📝 Committing all package changes..."
#
## Stage everything in the packages/ directory — new, modified, deleted
#if [ -d "packages" ]; then
#  git add -A packages
#  git commit -m "chore: sync all packages" || echo "✅ No package changes to commit"
#else
#  echo "❌ Error: 'packages' directory not found"
#  exit 1
#fi