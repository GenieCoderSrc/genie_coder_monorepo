// File: scripts/verify_published_version.dart

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

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart verify_published_version.dart <package_name> <expected_version>',
    );
    exit(1);
  }

  final packageName = args[0];
  final expectedVersion = args.length > 1 ? args[1] : null;

  final latestVersion = await fetchLatestVersion(packageName);

  if (latestVersion == null) {
    stderr.writeln('Could not fetch latest version for $packageName');
    exit(1);
  }

  if (expectedVersion != null && latestVersion != expectedVersion) {
    stderr.writeln(
      'Published version ($latestVersion) does not match expected ($expectedVersion)',
    );
    exit(1);
  }

  stdout.writeln('Verified published version on pub.dev: $latestVersion');
  exit(0);
}
