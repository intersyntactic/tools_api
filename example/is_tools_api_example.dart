import 'dart:convert';

import 'package:checked_json/checked_json.dart';
import 'package:is_tools_api/is_tools_api.dart';

final echo = ToolSpec(
  name: 'echo',
  description: 'Say the text back.',
  inputSchema: .of({
    'type': 'object',
    'properties': {
      'text': {'type': 'string'},
    },
    'required': ['text'],
  }),
  run: (input, context) async {
    context.onOutput?.call('echoing');
    return input.string('text');
  },
);

Future<void> main() async {
  // What a host sends the model.
  print(jsonEncode(echo.toJson()));

  // What a host does when the model calls the tool.
  final input = JsonObject.decode('{"text": "hello"}');
  final lines = <String>[];
  final reply = await echo.run(input, ToolContext(onOutput: lines.add));
  print('$reply (output: $lines)');
}
