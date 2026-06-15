#!/bin/bash
set -euo pipefail

# Configuration
ROOT_DIR="/Users/shoikat/Developer/FlutterDev/src/flutter_src/genie_coder_monorepo"
DATE=$(date +"%b %d, %Y")

echo "🚀 Starting Monorepo Version & Changelog Sync..."
cd "$ROOT_DIR"

# 1. Find all packages that have modified pubspec.yaml files compared to their own HEAD
for pkg_dir in packages/*; do
    if [ -d "$pkg_dir" ]; then
        pkg_name=$(basename "$pkg_dir")
        cd "$pkg_dir"

        if git diff --quiet pubspec.yaml; then
            cd "$ROOT_DIR"
            continue
        fi

        echo "📦 Processing $pkg_name..."

        UPDATES=$(git diff pubspec.yaml | grep '^\+  ' | grep -v 'sdk:' | sed 's/^\+  //' | sed 's/^ *//')

        if [ -z "$UPDATES" ]; then
            echo "   ⚠️ No dependency changes detected, skipping."
            cd "$ROOT_DIR"
            continue
        fi

        CURRENT_VERSION=$(grep 'version: ' pubspec.yaml | sed 's/version: //')
        V_MAJOR=$(echo $CURRENT_VERSION | cut -d. -f1)
        V_MINOR=$(echo $CURRENT_VERSION | cut -d. -f2)
        V_PATCH=$(echo $CURRENT_VERSION | cut -d. -f3 | cut -d+ -f1)
        NEW_PATCH=$((V_PATCH + 1))
        NEW_VERSION="$V_MAJOR.$V_MINOR.$NEW_PATCH"

        sed -i ".bak" "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" pubspec.yaml
        echo "   ✅ Bumped version: $CURRENT_VERSION -> $NEW_VERSION"

        if [ -f "CHANGELOG.md" ]; then
            ENTRY="## $NEW_VERSION\n\n### $DATE\n\n### ✨ Updated\n"
            while read -r line; do
                ENTRY+="- Updated \`$line\`\n"
            done <<< "$UPDATES"
            ENTRY+="\n"

            # FIX: Insert AFTER the header (usually line 2) instead of at line 1
            # We create a temp file to ensure the order: Header -> New Entry -> Rest of file
            HEADER="# Changelog\n\nAll notable changes to this project will be documented in this file.\n"
            tail -n +3 CHANGELOG.md > CHANGELOG.tmp
            echo -e "$HEADER\n$ENTRY" > CHANGELOG.md
            cat CHANGELOG.tmp >> CHANGELOG.md
            rm CHANGELOG.tmp
            echo "   ✅ Updated CHANGELOG.md (Header Preserved)"
        else
            echo "   ⚠️ No CHANGELOG.md found, skipping."
        fi

        git add pubspec.yaml CHANGELOG.md
        git commit -m "chore: bump version to $NEW_VERSION and update dependencies"
        git push origin main || echo "   ⚠️ Push failed."

        cd "$ROOT_DIR"
    fi
done

echo "🎉 All packages processed."
