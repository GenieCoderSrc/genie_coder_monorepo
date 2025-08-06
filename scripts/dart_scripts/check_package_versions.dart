// file: scripts/check_package_versions.dart

import 'dart:io';
import 'package:yaml/yaml.dart';

void main(List<String> args) {
  final packagesDir = Directory('packages');
  if (!packagesDir.existsSync()) {
    print('❌ "packages" directory does not exist');
    exit(1);
  }

  final packageDirs = packagesDir
      .listSync()
      .whereType<Directory>()
      .where((dir) => File('${dir.path}/pubspec.yaml').existsSync())
      .toList();

  if (packageDirs.isEmpty) {
    print('❌ No packages with pubspec.yaml found under "packages/"');
    exit(1);
  }

  print('📦 Package versions:');
  for (final dir in packageDirs) {
    final pubspecFile = File('${dir.path}/pubspec.yaml');
    final pubspecContent = pubspecFile.readAsStringSync();
    final yamlMap = loadYaml(pubspecContent) as YamlMap;

    final packageName = yamlMap['name'] ?? 'unknown';
    final version = yamlMap['version'] ?? 'unknown';

    print('- $packageName: $version');
  }
}
