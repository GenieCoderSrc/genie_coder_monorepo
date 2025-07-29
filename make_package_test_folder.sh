#!/bin/bash

set -e

echo "📦 Ensuring all packages have test folders and placeholder tests..."

# Loop through each package under packages/
for pkg in packages/*; do
  test_dir="$pkg/test"
  pubspec="$pkg/pubspec.yaml"
  pkg_name=$(basename "$pkg")

  # Ensure test folder exists
  mkdir -p "$test_dir"

  # Add placeholder test file if it doesn't already exist
  test_file="$test_dir/placeholder_test.dart"
  if [ ! -f "$test_file" ]; then
    cat > "$test_file" <<EOF
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder test for $pkg_name', () {
    expect(1, 1);
  });
}
EOF
    echo "✅ Added placeholder test to $pkg_name"
  fi

  # Add proper test dependencies
  if [ -f "$pubspec" ]; then
    if grep -q 'sdk: flutter' "$pubspec"; then
      if ! grep -q 'flutter_test:' "$pubspec"; then
        echo "➕ Adding flutter_test to $pubspec"
        echo -e '\ndev_dependencies:\n  flutter_test:\n    sdk: flutter' >> "$pubspec"
      fi
    else
      if ! grep -q 'test:' "$pubspec"; then
        echo "➕ Adding test package to $pubspec"
        echo -e '\ndev_dependencies:\n  test: ^1.24.0' >> "$pubspec"
      fi
    fi
  fi
done

echo "🔁 Bootstrapping with Melos..."
melos bootstrap

echo "✅ All test scaffolds and dependencies added successfully!"
