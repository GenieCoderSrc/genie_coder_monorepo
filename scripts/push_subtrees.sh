#!/bin/bash
set -e

PACKAGES_DIR="packages"
ORG_URL="https://github.com/GenieCoderSrc"

for dir in "$PACKAGES_DIR"/*/; do
  PACKAGE_NAME=$(basename "$dir")
  REPO_URL="$ORG_URL/$PACKAGE_NAME.git"

  echo "⬆️ Pushing $PACKAGE_NAME back to remote..."
  git subtree push --prefix="$PACKAGES_DIR/$PACKAGE_NAME" "$REPO_URL" main || echo "⚠️ Nothing to push"
done




✅ 2. Fix push_subtrees.sh to push all subtrees:

If you're pushing each subtree to its own remote (e.g., for each package), you'll need to do something like:

scripts/push_subtrees.sh:

#!/bin/bash
echo "🚀 Pushing all subtree packages..."

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

PACKAGES_DIR="$ROOT_DIR/packages"

for dir in "$PACKAGES_DIR"/*/; do
pkg_name=$(basename "$dir")
remote_name="subtree-$pkg_name"

Skip if no remote exists for this subtree
if git remote | grep -q "$remote_name"; then
echo "📦 Pushing $pkg_name to $remote_name..."
git subtree push --prefix="packages/$pkg_name" "$remote_name" main
else
echo "⚠️ Remote '$remote_name' not set for $pkg_name, skipping..."
fi
done

echo "✅ All subtree packages attempted to push."
