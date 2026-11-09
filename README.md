# is_tools_api

An intersyntactic tool's definition, as a host offers it to a model: its
name, description and input, and the types of what a call takes and returns.
A tool package depends on this, and on nothing else of intersyntactic's: not
the model client, not the airlock, not the path checks. So a tool's
definition can be written, read and tested without any of them.

```dart
import 'package:is_tools_api/is_tools_api.dart';

final class CloseIssue {
  const CloseIssue(this.number, this.comment);
  final int number;
  final String comment;
}

final closeIssue = ToolSpec<CloseIssue, String>(
  name: 'issue_close',
  description: 'Close an issue, saying why.',
  input: .fields2(
    Field('number', .integer(minimum: 1), description: 'The issue.'),
    Field('comment', .string(minLength: 1), description: 'Why it closes.'),
    CloseIssue.new,
  ),
);
```

The model is shown `minimum: 1` and `minLength: 1`, and the reader refuses
`{"number": 0}` with "`number` is not an integer from 1": one description,
so the rules the model is told are the rules it is held to.

## What is here

- `ToolSpec<I, O>`: a tool's name, description and `input`, and the types of
  what a call takes, `I`, and returns, `O`. `toJson()` is the definition in
  the Messages API's tool shape, and `wireBytes` its size in a request.
  `concurrent` says whether a host may carry out the tool's calls beside
  other calls; it is never sent.
- `Input<I>`: the object a tool takes, described once. `schema` is its JSON
  Schema, built from its fields and frozen all the way down; `read` turns the
  object the model sent into an `I`, or throws a `JsonFieldException` naming
  the field (`hunks[1]`, `at.line`). A field the schema does not name is
  refused (`additionalProperties: false`). Made by `Input.field`,
  `Input.none` and `Input.fields2` to `fields8`, which hand the fields'
  values, in order, to a function that makes the `I`. Dart has no type for
  "any number of fields", so the count is in the name, as in Elm's JSON
  decoders.
- `Field<T>`: a name, a `Schema<T>` and a description. Required as made;
  `Field.optional` reads an absent or null field as null, and
  `Field.orDefault` reads it as a value the schema also shows the model as
  its `default`.
- `Schema<T>`: one JSON value: `string`, `integer`, `number`, `boolean`,
  `choice` (a Dart enum, sent by name), `list` and `object`, with JSON
  Schema's own names for their constraints (`minLength`, `maxLength`,
  `minimum`, `maximum`, `minItems`, `maxItems`). The reader checks each
  constraint the schema shows.
- `O` is a shape: no field holds one, and the model never sees it, since the
  Messages API's tool shape has no return type. Whoever attaches the code
  that answers a call does it through the definition, so the analyzer checks
  that the code takes an `I` and returns an `O`, and anything waiting for an
  `O` can be bound to the tool. A `ToolSpec` written without its types is an
  inference failure under `strict-inference`.

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
