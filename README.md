# is_tools_api

The contract between an intersyntactic tool and the host that runs it. A tool
package depends on this, and on nothing else of intersyntactic's: not the
model client, not the code that runs programs, not the path checks. So a tool
can be written, read and tested without any of them.

```dart
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
  run: (input, context) async => input.string('text'),
);
```

## What is here

- `ToolSpec`: a tool's name, description and input schema, and the `run` that
  answers a call. The schema is frozen all the way down when the tool is made,
  so a later change to the map it came from cannot change what the model is
  told. `toJson()` is the definition in the Messages API's tool shape.
  `concurrent` says whether a host may run the tool beside other calls; it is
  never sent.
- `ToolContext`: what one call tells its host while it runs: its output a line
  at a time, the processes it starts, the images it attaches. It is an
  argument to every call, never ambient, so two calls running at once cannot
  mix their output. `ToolContext.none` when nothing is listening.
- `ToolImage` and `ToolProcessTap`: an attached image, and the shape of a
  process hook.

The library imports `checked_json` and `dart:convert` and nothing else; a test
holds it to that.

## The name

pub.dev has one namespace for everyone, so the package is `is_tools_api` there
and in every import. The repository is
[intersyntactic/tools_api](https://github.com/intersyntactic/tools_api).
