#!/bin/bash

# Global configuration
GITHUB_ORG="GenieCoderSrc"
PACKAGES_DIR="packages"

# Initialize and get root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

function commit_all_changes() {
  echo "📝 Committing all changes..."
  git add .
  git commit -m "chore: sync all packages" || echo "⚠️ Nothing to commit"
}

function add_remote() {
  local remote_name="$1"
  local repo_name="$2"

  if ! git remote | grep -q "^$remote_name$"; then
    git remote add "$remote_name" "git@github.com:$GITHUB_ORG/$repo_name.git"
    echo "✅ Added remote $remote_name"
  else
    echo "🔁 Remote $remote_name exists"
  fi
}


# ────────────────────────────────────────────────
# 🌐 Get all package names under the packages/ folder
# ────────────────────────────────────────────────
function get_package_names() {
  find "$PACKAGES_DIR" -maxdepth 1 -mindepth 1 -type d \
    -not -name '.*' \
    -not -name '.idea' \
    -not -name '.vscode' \
    -exec basename {} \; | sort
}

# ────────────────────────────────────────────────
# 🚀 Push package via git subtree if changed
# ────────────────────────────────────────────────
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
#  local local_head=$(git rev-parse HEAD)
#  local remote_head=$(git ls-remote --heads "$remote_name" main | awk '{print $1}')
#
#  if [ -z "$remote_head" ]; then
#    echo "🌱 First push to new repository"
#    git subtree push --prefix="$package_path" "$remote_name" main
#    return 0
#  fi
#
#  local common_ancestor=$(git merge-base "$local_head" "$remote_head")
#
#  if ! git diff --quiet "$common_ancestor" HEAD -- "$package_path"; then
#    echo "🚀 Pushing changes..."
#    git subtree push --prefix="$package_path" "$remote_name" main
#    echo "✓ Successfully pushed $package_path"
#  else
#    echo "✅ $package_path: No changes in package directory since last push"
#  fi
#}


function push_subtree() {
  local package_path="$1"
  local remote_name="$2"

  if git remote | grep -q "^$remote_name$"; then
    echo "🚀 Pushing subtree: $package_path → $remote_name"
    git subtree push --prefix="$package_path" "$remote_name" main
  else
    echo "❌ Remote '$remote_name' not found"
    return 1
  fi
}

