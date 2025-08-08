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

ALL_PACKAGES=()

for pkg in $CHANGED_PACKAGES; do
  ALL_PACKAGES+=("$pkg")

  echo "🔗 Finding dependents of package: $pkg"
  DEPENDENTS=$(melos list --depends-on="$pkg" --include-dependents --json | jq -r '.[].name')

  if [ -n "$DEPENDENTS" ]; then
    echo "➡️ Dependents found: $DEPENDENTS"
    for dep in $DEPENDENTS; do
      ALL_PACKAGES+=("$dep")
    done
  else
    echo "➡️ No dependents found for $pkg"
  fi
done

# Remove duplicates
ALL_PACKAGES=($(printf "%s\n" "${ALL_PACKAGES[@]}" | sort -u))

echo "🚀 Packages to force version bump and update changelogs:"
printf '%s\n' "${ALL_PACKAGES[@]}"

# Join by comma for melos flag
FORCE_PUBLISH_CSV=$(IFS=,; echo "${ALL_PACKAGES[*]}")

#echo "🔧 Running version bump..."
#melos version --force-publish="$FORCE_PUBLISH_CSV" --yes

echo "🔢 Running version bump (will update dependents automatically)..."
melos version --yes

echo "✅ Version bump complete"
#melos changelog


echo "✅ Done!"
