import 'dart:convert';
import 'dart:io';

/// Runs a Melos command and returns decoded JSON result.
/// [diff] if true, runs `melos list --diff=origin/main --json`
Future<List<Map<String, dynamic>>> fetchPackages({bool diff = false}) async {
  final args = ['list', '--json'];
  if (diff) {
    args.insert(1, '--diff=origin/main');
  }
  final result = await Process.run('melos', args);
  if (result.exitCode != 0) {
    stderr.writeln('Error running melos: ${result.stderr}');
    exit(1);
  }
  return (jsonDecode(result.stdout) as List).cast<Map<String, dynamic>>();
}

/// Bumps a semantic version string based on your rule:
/// If patch < 9, patch++
/// If patch == 9, patch=0 and minor++
String bumpVersion(String version) {
  final parts = version.split('.').map(int.parse).toList();
  if (parts.length != 3) {
    stderr.writeln('Invalid version format: $version');
    exit(1);
  }
  if (parts[2] == 9) {
    parts[2] = 0;
    parts[1] += 1;
  } else {
    parts[2] += 1;
  }
  return parts.join('.');
}

/// Runs `melos version` command to bump a package version with a commit message.
Future<void> runMelosVersion(
  String packageName,
  String version,
  String commitMessage,
) async {
  final args = [
    'version',
    packageName,
    version,
    '--yes',
    '--message',
    commitMessage,
  ];
  final result = await Process.run('melos', args);
  if (result.exitCode != 0) {
    stderr.writeln('Failed to bump $packageName: ${result.stderr}');
    exit(1);
  }
  print('Bumped $packageName to $version');
}

/// Builds a map of package name to list of its dependents (reverse dependencies).
Map<String, List<String>> buildDependentsMap(
  List<Map<String, dynamic>> packages,
) {
  final Map<String, List<String>> dependentsMap = {};
  for (final pkg in packages) {
    final name = pkg['name'] as String;
    final dependencies =
        (pkg['dependencies'] as Map?)?.keys.cast<String>() ?? [];
    for (final dep in dependencies) {
      dependentsMap.putIfAbsent(dep, () => []).add(name);
    }
  }
  return dependentsMap;
}

/// Recursively bumps package versions and their dependents.
/// Tracks bumped packages to avoid duplicates.
/// Generates commit messages with dependency info.
Future<void> recursiveBump(
  String packageName,
  String newVersion,
  Map<String, Map<String, dynamic>> packageMap,
  Map<String, List<String>> dependentsMap,
  Set<String> bumped, {
  String? parentPackage,
}) async {
  if (bumped.contains(packageName)) return;

  final commitMsg = parentPackage == null
      ? 'feat($packageName): manual version bump to $newVersion'
      : 'Updated $parentPackage version to $newVersion';

  await runMelosVersion(packageName, newVersion, commitMsg);
  bumped.add(packageName);

  final dependents = dependentsMap[packageName] ?? [];
  for (final dep in dependents) {
    if (!bumped.contains(dep)) {
      final curVer = packageMap[dep]!['version'] as String;
      final bumpedVer = bumpVersion(curVer);
      await recursiveBump(
        dep,
        bumpedVer,
        packageMap,
        dependentsMap,
        bumped,
        parentPackage: packageName,
      );
    }
  }
}

Future<void> main() async {
  // Load all packages info and changed packages info
  final allPackages = await fetchPackages();
  final changedPackages = await fetchPackages(diff: true);

  if (changedPackages.isEmpty) {
    print('✅ No changed packages found.');
    return;
  }

  // Build quick-access map of packageName -> packageInfo
  final packageMap = {for (var pkg in allPackages) pkg['name'] as String: pkg};

  // Build dependency graph: package -> list of dependents
  final dependentsMap = buildDependentsMap(allPackages);

  final bumped = <String>{};

  for (final pkg in changedPackages) {
    final name = pkg['name'] as String;
    final currentVersion = pkg['version'] as String;

    stdout.write(
      'Current version of $name is $currentVersion\nEnter new version (empty = patch bump): ',
    );
    final input = stdin.readLineSync();
    final newVersion = (input == null || input.trim().isEmpty)
        ? bumpVersion(currentVersion)
        : input.trim();

    await recursiveBump(name, newVersion, packageMap, dependentsMap, bumped);
  }

  print('✅ All version bumps complete.');
}
