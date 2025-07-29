#!/bin/bash
set -e

# Global configuration
GITHUB_ORG="GenieCoderSrc"
PACKAGES_DIR="packages"
USE_SPLIT=false  # Set to true to use subtree split method
EXCLUDE_DIRS=(".idea" ".vscode" ".DS_Store")  # Directories to exclude

# Get root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Function to get all package names (excluding hidden and IDE directories)
function get_package_names() {
  find "$PACKAGES_DIR" -maxdepth 1 -mindepth 1 -type d \
    -not -name '.*' \
    -not -name '.idea' \
    -not -name '.vscode' \
    -exec basename {} \; | sort
}

function push_subtree() {
  local package_path="$1"
  local remote_name="$2"

  if ! git remote | grep -q "^$remote_name$"; then
    echo "❌ Remote '$remote_name' not found (skipping)"
    return 0  # Change to return 1 if you want to fail on missing remotes
  fi

  echo "📦 Checking $package_path → $remote_name..."

  # Check for new commits
  if ! git log "$remote_name/main..HEAD" -- "$package_path" | grep -q .; then
    echo "✅ $package_path: No new changes to push"
    return 0
  fi

  # Push using preferred method
  if $USE_SPLIT; then
    echo "✂️ Using subtree split + push..."
    split_sha=$(git subtree split --prefix="$package_path" main)
    git push "$remote_name" "$split_sha:main"
  else
    echo "🚀 Pushing changes..."
    git subtree push --prefix="$package_path" "$remote_name" main
  fi

  echo "✓ Successfully pushed $package_path"
}

# Main execution
echo "🚀 Pushing package subtrees to their remotes..."
cd "$ROOT_DIR" || exit 1

for pkg in $(get_package_names); do
  push_subtree "$PACKAGES_DIR/$pkg" "subtree-$pkg"
done

echo "🌿 All subtree pushes completed"