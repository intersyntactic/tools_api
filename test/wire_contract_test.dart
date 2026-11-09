import 'dart:convert';

import 'package:test/test.dart';
import 'package:is_tools_api/is_tools_api.dart';

void main() {
  test('tool definition wire shape excludes execution metadata', () {
    final spec = ToolSpec<String>(
      name: 'file_read',
      description: 'Read a file.',
      inputSchema: .of({
        'type': 'object',
        'properties': {
          'path': {'type': 'string'},
        },
        'required': ['path'],
      }),
      concurrent: true,
    );
    const wire =
        '{"name":"file_read","description":"Read a file.",'
        '"input_schema":{"type":"object","properties":'
        '{"path":{"type":"string"}},"required":["path"]}}';
    expect(jsonEncode(spec.toJson()), wire);
    expect(spec.wireBytes, utf8.encode(wire).length);
  });
}
