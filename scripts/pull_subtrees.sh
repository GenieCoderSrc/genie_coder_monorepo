#!/bin/bash
set -e

PACKAGES_DIR="packages"
ORG_URL="https://github.com/GenieCoderSrc"

for dir in "$PACKAGES_DIR"/*/; do
  PACKAGE_NAME=$(basename "$dir")
  REPO_URL="$ORG_URL/$PACKAGE_NAME.git"

  echo "⬇️ Pulling latest from $PACKAGE_NAME..."
  git subtree pull --prefix="$PACKAGES_DIR/$PACKAGE_NAME" "$REPO_URL" main || echo "⚠️ Nothing to pull"
#  git subtree pull --prefix="$PACKAGES_DIR/$PACKAGE_NAME" "$REPO_URL" main --squash || echo "⚠️ Nothing to pull"
done

