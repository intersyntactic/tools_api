import 'dart:convert';

import 'package:is_tools_api/is_tools_api.dart';

final echo = ToolSpec<String>(
  name: 'echo',
  description: 'Say the text back.',
  inputSchema: .of({
    'type': 'object',
    'properties': {
      'text': {'type': 'string'},
    },
    'required': ['text'],
  }),
);

void main() {
  // What a host sends the model, and what it costs in a request.
  print(jsonEncode(echo.toJson()));
  print('${echo.wireBytes} bytes');
}
