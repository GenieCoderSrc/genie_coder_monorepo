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

echo "📦 Packages to bump:"
echo "$ALL_PACKAGES"

# 4. Build melos manual-version args
ARGS=""
for PKG in $ALL_PACKAGES; do
  ARGS+=" --manual-version $PKG:patch"
  echo "📦 Current  ARGS: $ARGS"
done

# 5. Version bump with changelog update
echo "🚀 Bumping versions & updating changelogs..."
melos version --yes $ARGS

## 6. Commit changes
#echo "💾 Committing version changes..."
#git add .
#git commit -m "chore: auto bump packages and update changelogs"
#
# 7. Publish updated packages
#echo "📤 Publishing packages..."
#melos publish --yes --no-private

echo "🎉 Done!"
