#!/bin/bash
set -euo pipefail

# Initialize the global array immediately so 'set -u' doesn't complain
RECURSIVE_PUBLISH_LIST=()

# Function to recursively find all dependent packages
get_all_dependents_recursive() {
  local target_pkg="$1"
  
  # Fetch immediate dependents using Melos
  local dependents
  dependents=$(melos list --depends-on="$target_pkg" --include-dependents --json 2>/dev/null | jq -r '.[].name' || true)
  
  for dep in $dependents; do
    # Prevent infinite loops by checking if the package is already tracked
    if [[ " ${RECURSIVE_PUBLISH_LIST[*]:-} " =~ " ${dep} " ]]; then
      continue
    fi
    
    RECURSIVE_PUBLISH_LIST+=("$dep")
    # Deep dive into downstream dependents
    get_all_dependents_recursive "$dep"
  done
}

# Main execution function
list_packages_to_republish() {
  echo "⏳ Fetching latest origin/main..."
  git fetch origin main --quiet

  echo "🔍 Detecting initial changed packages compared to origin/main..."
  local root_changes
  root_changes=$(melos list --diff=origin/main --json 2>/dev/null | jq -r '.[].name' || true)

  if [ -z "$root_changes" ]; then
    echo "✅ No changed packages detected."
    exit 0
  fi

  echo "🌳 Resolving complete recursive dependency chains..."
  for pkg in $root_changes; do
    if [[ ! " ${RECURSIVE_PUBLISH_LIST[*]:-} " =~ " ${pkg} " ]]; then
      RECURSIVE_PUBLISH_LIST+=("$pkg")
    fi
    get_all_dependents_recursive "$pkg"
  done

  # macOS Compatible Deduplication (Replaces mapfile)
  FINAL_PUBLISH_LIST=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && FINAL_PUBLISH_LIST+=("$line")
  done < <(printf "%s\n" "${RECURSIVE_PUBLISH_LIST[@]}" | sort -u)

  echo -e "\n🚀 Packages to force version bump and update changelogs (${#FINAL_PUBLISH_LIST[@]}):"
  printf '  - %s\n' "${FINAL_PUBLISH_LIST[@]}"

  # Join by comma for melos flag usage
  local force_publish_csv
  force_publish_csv=$(IFS=,; echo "${FINAL_PUBLISH_LIST[*]}")

  echo -e "\n🔧 Running version bump..."
  melos version --force-publish="$force_publish_csv" --yes

  echo "📝 Generating changelogs for bumped packages..."
  melos changelog

  echo "✅ Done!"
}

# Execute the main routine
list_packages_to_republish