#!/bin/bash
set -euo pipefail

echo "⏳ Fetching latest origin/main..."
git fetch origin main

echo "🔍 Detecting changed packages compared to origin/main..."
CHANGED_PACKAGES=$(melos list --diff=origin/main --json | jq -r '.[].name')

if [ -z "$CHANGED_PACKAGES" ]; then
  echo "✅ No changed packages detected."
  exit 0
fi

echo "📦 Changed packages:"
echo "$CHANGED_PACKAGES"

FORCE_PUBLISH_LIST=()

for pkg in $CHANGED_PACKAGES; do
  FORCE_PUBLISH_LIST+=("$pkg")

  echo "🔗 Finding dependents of package: $pkg"
  DEPENDENTS=$(melos list --depends-on="$pkg" --include-dependents --json | jq -r '.[].name')

  if [ -n "$DEPENDENTS" ]; then
    echo "➡️ Dependents found: $DEPENDENTS"
    for dep in $DEPENDENTS; do
      FORCE_PUBLISH_LIST+=("$dep")
    done
  else
    echo "➡️ No dependents found for $pkg"
  fi
done

# Remove duplicates
FORCE_PUBLISH_LIST=($(printf "%s\n" "${FORCE_PUBLISH_LIST[@]}" | sort -u))

echo "🚀 Packages to force version bump and update changelogs:"
printf '%s\n' "${FORCE_PUBLISH_LIST[@]}"

# Join by comma for melos flag
FORCE_PUBLISH_CSV=$(IFS=,; echo "${FORCE_PUBLISH_LIST[*]}")

echo "🔧 Running version bump..."
melos version --force-publish="$FORCE_PUBLISH_CSV" --yes

echo "📝 Generating changelogs for bumped packages..."
melos changelog

echo "✅ Done!"
