#!/bin/bash
set -e

# Temporary file for old versions
OLD_VERSIONS_FILE=".old_versions.txt"

# Save current versions before change
if [ ! -f "$OLD_VERSIONS_FILE" ]; then
    echo "Saving current versions..."
    find packages -name "pubspec.yaml" -type f | while read -r file; do
        version=$(grep '^version:' "$file" | awk '{print $2}')
        echo "$file $version"
    done > "$OLD_VERSIONS_FILE"
    echo "✅ Versions saved."
    exit 0
fi

echo "🔍 Checking for version changes..."
while read -r path old_version; do
    new_version=$(grep '^version:' "$path" | awk '{print $2}')
    if [ "$old_version" != "$new_version" ]; then
        echo "📦 $(basename "$(dirname "$path")"): $old_version → $new_version"
    fi
done < "$OLD_VERSIONS_FILE"

# Update stored versions for next run
find packages -name "pubspec.yaml" -type f | while read -r file; do
    version=$(grep '^version:' "$file" | awk '{print $2}')
    echo "$file $version"
done > "$OLD_VERSIONS_FILE"
