#!/bin/bash

set -euo pipefail

# Color definitions for better logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
  echo -e "${RED}❌ $1${NC}" >&2
}

log_step() {
  echo -e "\n${CYAN}>>> $1${NC}\n"
}

# Go to repo root
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || { log_error "Failed to cd into repo root"; exit 1; }

log_step "📦 Melos Bootstrap & Publish Script Started"

# 1. Bootstrap dependencies
log_step "🔁 Running melos bootstrap..."
if melos bootstrap; then
  log_success "Bootstrap complete"
else
  log_error "Bootstrap failed"
  exit 1
fi

# 2. (Optional) Run tests
if [[ "${RUN_TESTS:-false}" == "true" ]]; then
  log_step "🧪 Running tests for all packages..."
  if melos run test; then
    log_success "All tests passed"
  else
    log_error "Tests failed, aborting."
    exit 1
  fi
fi

# 3. Version bump
log_step "🔢 Running melos version (auto version bump)..."
if melos version --yes --all; then
  log_success "Version bump complete"
else
  log_error "Version bump failed"
  exit 1
fi

# 4. Formatting
log_step "🧼 Running code formatting on all packages..."
if melos run format; then
  log_success "Formatting done"
else
  log_warning "Formatting failed, but continuing"
fi

# 5. Commit and push changes
log_step "📌 Committing version bump and pushing to remote repository..."
if [[ -n "$(git status --porcelain)" ]]; then
  git add .

  # Prevent accidental workflow push
  if git diff --cached --name-only | grep -q "^\.github/workflows/"; then
    log_error "Detected workflow file changes requiring special PAT scopes. Aborting push."
    exit 1
  fi

  git commit -m "🔖 chore: version bump and publish packages"

  if git push; then
    log_success "Changes pushed to GitHub"
  else
    log_error "Failed to push changes"
    exit 1
  fi
else
  log_info "No changes to commit"
fi

# 6. Dry run publish
log_step "🔍 Running dry run publish for all packages..."
if melos publish --dry-run; then
  log_success "Dry run successful"
else
  log_error "Dry run failed"
  exit 1
fi

# 7. Publish
log_step "🚀 Publishing all packages to pub.dev..."
if melos publish --yes; then
  log_success "All packages published successfully!"
else
  log_error "Publishing failed"
  exit 1
fi

log_step "🎉 Melos Bootstrap & Publish Script Completed Successfully"
