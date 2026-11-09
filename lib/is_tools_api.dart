/// A tool's definition, as a host offers it to a model: its name,
/// description and input schema.
///
/// A host chooses which tools to expose, in its kit. The code that answers a
/// call, and what a call reports while it runs, are the airlock's, so this
/// library holds no kit, scheduling, model client, runs or effects: only the
/// definition.
library;

import 'dart:convert';

import 'package:checked_json/checked_json.dart';

/// One tool's definition: its name, description and input schema, and [O],
/// the type of what a call returns.
///
/// No field holds an [O]. The code that answers a call is the airlock's, and
/// it is attached through this definition, so the analyzer checks that it
/// returns an [O]: a shape another tool or module can be bound to. [O] is
/// never sent to the model; the Messages API's tool shape has no return type.
class ToolSpec<O> {
  final String name;
  final String description;

  /// A frozen snapshot of the completed JSON Schema, including nested maps
  /// and lists. Finish building a schema before passing it here: later edits
  /// to the original do not change the tool's definition.
  final JsonObject inputSchema;

  /// Whether a host may carry out this tool's calls alongside other calls in
  /// the same batch. False by default: writes must not race reads or other
  /// writes. This is execution metadata, not part of the rendered definition.
  final bool concurrent;

  ToolSpec({
    required this.name,
    required this.description,
    required JsonObject inputSchema,
    this.concurrent = false,
  }) : inputSchema = inputSchema.deepFrozen();

  /// The definition rendered by hosts that use the Messages tool shape.
  JsonObject toJson() => .of({
    'name': name,
    'description': description,
    'input_schema': inputSchema,
  });

  /// UTF-8 bytes this definition contributes to a request.
  int get wireBytes => utf8.encode(jsonEncode(toJson())).length;
}
