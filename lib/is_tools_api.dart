/// A tool's definition, as a host offers it to a model: its name,
/// description and input, and the types of what a call takes and returns.
///
/// A host chooses which tools to expose, in its kit. The code that answers a
/// call, and what a call reports while it runs, are the airlock's, so this
/// library holds no kit, scheduling, model client, runs or effects: only the
/// definition.
library;

import 'dart:convert';

import 'package:checked_json/checked_json.dart';

import 'src/input.dart';

export 'src/input.dart';

/// One tool's definition: its name, description and [input], and the types
/// of what a call takes, [I], and returns, [O].
///
/// [input] tells the model the object to send and reads the object it sent
/// as an [I], from one description. No field holds an [O]. The code that
/// answers a call is the airlock's, and it is attached through this
/// definition, so the analyzer checks that it takes an [I] and returns an
/// [O]: a shape another tool or module can be bound to. [O] is never sent to
/// the model; the Messages API's tool shape has no return type.
class ToolSpec<I, O> {
  final String name;
  final String description;

  /// What a call takes: the schema the model is shown, and the reader of
  /// what it sent.
  final Input<I> input;

  /// Whether a host may carry out this tool's calls alongside other calls in
  /// the same batch. False by default: writes must not race reads or other
  /// writes. This is execution metadata, not part of the rendered definition.
  final bool concurrent;

  ToolSpec({
    required this.name,
    required this.description,
    required this.input,
    this.concurrent = false,
  });

  /// [input]'s JSON Schema, frozen all the way down.
  JsonObject get inputSchema => input.schema;

  /// The definition rendered by hosts that use the Messages tool shape.
  JsonObject toJson() => .of({
    'name': name,
    'description': description,
    'input_schema': inputSchema,
  });

  /// UTF-8 bytes this definition contributes to a request.
  int get wireBytes => utf8.encode(jsonEncode(toJson())).length;
}
