#!/bin/bash

set -e
source "$(dirname "$0")/functions.sh"

PACKAGES_DIR="packages"
cd "$(git rev-parse --show-toplevel)"

echo "🚀 Pushing subtrees..."
for pkg in $(get_package_names); do
  remote_name="remote_$pkg"
  push_subtree "$PACKAGES_DIR/$pkg" "$remote_name"
done


##!/bin/bash
#set -e
#
## Global configuration
#GITHUB_ORG="GenieCoderSrc"
#PACKAGES_DIR="packages"
#USE_SPLIT=false
#
## Get root directory
#ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
#
#function get_package_names() {
#  find "$PACKAGES_DIR" -maxdepth 1 -mindepth 1 -type d \
#    -not -name '.*' \
#    -not -name '.idea' \
#    -not -name '.vscode' \
#    -exec basename {} \; | sort
#}
#
#function push_subtree() {
#  local package_path="$1"
#  local remote_name="$2"
#
#  if ! git remote | grep -q "^$remote_name$"; then
#    echo "❌ Remote '$remote_name' not found (skipping)"
#    return 0
#  fi
#
#  echo "📦 Checking $package_path → $remote_name..."
#
#  # Get local and remote HEAD commits
#  local local_head=$(git rev-parse HEAD)
#  local remote_head=$(git ls-remote --heads "$remote_name" main | awk '{print $1}')
#
#  # If remote doesn't exist yet
#  if [ -z "$remote_head" ]; then
#    echo "🌱 First push to new repository"
#    git subtree push --prefix="$package_path" "$remote_name" main
#    return 0
#  fi
#
#  # Find common ancestor
#  local common_ancestor=$(git merge-base "$local_head" "$remote_head")
#
#  # Check for changes in the package directory since common ancestor
#  if ! git diff --quiet "$common_ancestor" HEAD -- "$package_path"; then
#    echo "🚀 Pushing changes..."
#    git subtree push --prefix="$package_path" "$remote_name" main
#    echo "✓ Successfully pushed $package_path"
#  else
#    echo "✅ $package_path: No changes in package directory since last push"
#  fi
#}
#
## Main execution
#echo "🚀 Pushing package subtrees to their remotes..."
#cd "$ROOT_DIR" || exit 1
#
#for pkg in $(get_package_names); do
#  push_subtree "$PACKAGES_DIR/$pkg" "subtree-$pkg"
#done
#
#echo "🌿 All subtree pushes completed"