#!/bin/bash
set -e

PACKAGES_DIR="packages"
ORG_URL="https://github.com/GenieCoderSrc"

for dir in "$PACKAGES_DIR"/*/; do
  PACKAGE_NAME=$(basename "$dir")
  REMOTE_EXISTS=$(git remote | grep -w "$PACKAGE_NAME" || true)

  if [ -z "$REMOTE_EXISTS" ]; then
    echo "🔗 Adding remote for $PACKAGE_NAME..."
    git remote add "$PACKAGE_NAME" "$ORG_URL/$PACKAGE_NAME.git"
  else
    echo "✅ Remote for $PACKAGE_NAME already exists"
  fi
done




#✅ 3. Optionally, separate the add remotes script

#scripts/add_remotes.sh:

#!/bin/bash
echo "🔗 Adding remotes for all subtree packages..."

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

GITHUB_ORG="GenieCoderSrc"
PACKAGES_DIR="$ROOT_DIR/packages"

for dir in "$PACKAGES_DIR"/*/; do
pkg_name=$(basename "$dir")
remote_name="subtree-$pkg_name"
remote_url="git@github.com:$GITHUB_ORG/$pkg_name.git"

if git remote | grep -q "$remote_name"; then
echo "🔁 Remote $remote_name already exists."
else
git remote add "$remote_name" "$remote_url"
echo "✅ Added remote $remote_name → $remote_url"
fi
done


