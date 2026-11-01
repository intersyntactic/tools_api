import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('shared contracts do not import runners, tools, clients or effects', () {
    final directives = RegExp(r'''\b(?:import|export)\s+['"]([^'"]+)['"]''');
    const allowedSdk = {
      'dart:async',
      'dart:collection',
      'dart:convert',
      'dart:core',
      'dart:math',
      'dart:typed_data',
    };
    final violations = <String>[];
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      for (final match in directives.allMatches(file.readAsStringSync())) {
        final target = match.group(1)!;
        final uri = Uri.parse(target);
        final allowed = switch (uri.scheme) {
          'dart' => allowedSdk.contains(target),
          'package' => const {
            'checked_json',
            'is_tools_api',
          }.contains(uri.pathSegments.first),
          '' => !uri.isAbsolute && !uri.pathSegments.contains('..'),
          _ => false,
        };
        if (!allowed) violations.add('${file.path}: $target');
      }
    }
    expect(
      violations,
      isEmpty,
      reason:
          'is_tools_api supplies contracts, not clients, runners or effects',
    );
  });
}
