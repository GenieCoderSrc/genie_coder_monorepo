// File: scripts/check_version_bump.dart

import 'dart:convert';
import 'dart:io';

Future<String?> fetchLatestVersion(String packageName) async {
  final url = Uri.parse('https://pub.dev/api/packages/$packageName');
  final response = await HttpClient().getUrl(url).then((req) => req.close());
  if (response.statusCode != 200) return null;
  final json = await response.transform(utf8.decoder).join();
  final data = jsonDecode(json);
  return data['latest']['version'] as String?;
}

Future<String?> getLocalVersion(String pubspecPath) async {
  final file = File(pubspecPath);
  if (!await file.exists()) return null;
  final lines = await file.readAsLines();
  for (var line in lines) {
    if (line.startsWith('version:')) {
      return line.split(':')[1].trim();
    }
  }
  return null;
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart check_version_bump.dart <package_name> [pubspec_path]',
    );
    exit(1);
  }

  final packageName = args[0];
  final pubspecPath = args.length > 1 ? args[1] : 'pubspec.yaml';

  final latestVersion = await fetchLatestVersion(packageName);
  final localVersion = await getLocalVersion(pubspecPath);

  if (localVersion == null) {
    stderr.writeln('Error: Could not find version in $pubspecPath');
    exit(1);
  }

  if (latestVersion == null) {
    // Possibly first publish, no version on pub.dev yet
    stdout.writeln(
      'No version found on pub.dev for $packageName. Continue publishing.',
    );
    exit(0);
  }

  if (localVersion == latestVersion) {
    stderr.writeln(
      'Version mismatch: Local version ($localVersion) matches latest pub.dev version ($latestVersion). Please bump version.',
    );
    exit(1);
  }

  stdout.writeln(
    'Version bump check passed: Local ($localVersion) vs Latest pub.dev ($latestVersion)',
  );
  exit(0);
}
