#!/bin/bash

set -e

# Inside monorepo root
PACKAGES_PATH="packages"
ORG_URL="https://github.com/GenieCoderSrc"

echo "📦 Scanning packages in $PACKAGES_PATH..."

# Loop through each directory in packages/
for dir in "$PACKAGES_PATH"/*/; do
  PACKAGE_NAME=$(basename "$dir")
  SUBFOLDER="$PACKAGES_PATH/$PACKAGE_NAME"
  REPO_URL="$ORG_URL/$PACKAGE_NAME.git"

  echo ""
  echo "🚀 Importing $PACKAGE_NAME into $SUBFOLDER ..."

  git remote add "$PACKAGE_NAME" "$REPO_URL"
  git fetch "$PACKAGE_NAME"

  # If the package uses another branch, adjust 'main' here
  git subtree add --prefix="$SUBFOLDER" "$PACKAGE_NAME"/main --squash

  git remote remove "$PACKAGE_NAME"

  echo "✅ Imported $PACKAGE_NAME"
done

echo ""
echo "🎉 All packages imported successfully into $PACKAGES_PATH/"
