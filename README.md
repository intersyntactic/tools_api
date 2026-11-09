# is_tools_api

An intersyntactic tool's definition, as a host offers it to a model: its
name, description and input schema. A tool package depends on this, and on
nothing else of intersyntactic's: not the model client, not the airlock, not
the path checks. So a tool's definition can be written, read and tested
without any of them.

```dart
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
```

## What is here

- `ToolSpec<O>`: a tool's name, description and input schema, and `O`, the
  type of what a call returns. The schema is frozen all the way down when the
  tool is made, so a later change to the map it came from cannot change what
  the model is told. `toJson()` is the definition in the Messages API's tool
  shape, and `wireBytes` its size in a request. `concurrent` says whether a
  host may carry out the tool's calls beside other calls; it is never sent.
- `O` is a shape: no field holds one, and the model never sees it, since the
  Messages API's tool shape has no return type. Whoever attaches the code
  that answers a call does it through the definition, so the analyzer checks
  that the code returns an `O`, and anything waiting for an `O` can be bound
  to the tool. A `ToolSpec` written without `<O>` is an inference failure
  under `strict-inference`.

## What is not here

The code that answers a call, and what a call reports while it runs. In
intersyntactic the model plans, tools describe effects, the airlock decides
and records, and drivers operate the world, so those belong to the airlock.
Until 0.2.0 they were here, as `ToolSpec.run`, `ToolContext`, `ToolImage`
and `ToolProcessTap`.

The library imports `checked_json` and `dart:convert` and nothing else; a test
holds it to that.

## The name

pub.dev has one namespace for everyone, so the package is `is_tools_api` there
and in every import. The repository is
[intersyntactic/tools_api](https://github.com/intersyntactic/tools_api).
