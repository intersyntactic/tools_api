/// Shared contracts for tools, their callers and their runners.
///
/// A tool owns its schema and implementation. A host chooses which tools to
/// expose; a runner invokes them. This library supplies only the contract
/// between those pieces, with no roster, scheduling, model client or effects.
library;

import 'dart:convert';

import 'package:checked_json/checked_json.dart';

/// One tool: its input schema and the code that runs it.
class ToolSpec {
  final String name;
  final String description;

  /// A frozen snapshot of the completed JSON Schema, including nested maps
  /// and lists. Finish building a schema before passing it here: later edits
  /// to the original do not change the tool's definition.
  final JsonObject inputSchema;

  /// Runs with the call's explicit output, process and image hooks.
  /// Every invocation supplies a context, using [ToolContext.none] when
  /// nothing is listening. A tool may ignore it, but there is no input-only
  /// adapter that can silently discard a caller's hooks.
  final Future<String> Function(JsonObject input, ToolContext context) run;

  /// Whether a runner may run this alongside other calls in the same batch.
  /// False by default: writes must not race reads or other writes.
  /// This is execution metadata, not part of the rendered definition.
  final bool concurrent;

  ToolSpec({
    required this.name,
    required this.description,
    required JsonObject inputSchema,
    required this.run,
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

/// What one tool call tells its host while it runs.
///
/// Hooks travel as an explicit argument, so concurrent calls cannot mix
/// their output or processes. This contract observes effects; it does not
/// grant permission to perform them.
class ToolContext {
  const ToolContext({this.onOutput, this.onProcess, this.images});

  /// Nothing is listening.
  static const none = ToolContext();

  /// Where [attachImage] collects this call's images; null when the host
  /// does not accept them.
  final List<ToolImage>? images;

  /// Attaches a base64 image to this call's result, next to its text.
  /// [thumbnail] is for the person's transcript only, never a model.
  void attachImage(String mediaType, String base64Data, {String? thumbnail}) =>
      images?.add(ToolImage(mediaType, base64Data, thumbnail: thumbnail));

  /// A call's output a line at a time, as it is printed.
  final void Function(String line)? onOutput;

  /// A process started (ended false) or released its output pipes (true).
  /// Closing pipes is distinct from exiting: a grandchild may keep them open.
  final ToolProcessTap? onProcess;

  /// This context collecting attached images into [into].
  ToolContext withImages(List<ToolImage> into) =>
      ToolContext(onOutput: onOutput, onProcess: onProcess, images: into);

  /// Transform output without dropping process or image hooks.
  ToolContext withOutput(void Function(String line) f) =>
      ToolContext(onOutput: f, onProcess: onProcess, images: images);
}

/// An image a tool attached to its result.
class ToolImage {
  const ToolImage(this.mediaType, this.data, {this.thumbnail});
  final String mediaType;

  /// A small base64 PNG for display; not sent to any model.
  final String? thumbnail;

  /// Base64 image data.
  final String data;
}

/// Observes a call's process-group leader and its output-pipe lifecycle.
typedef ToolProcessTap = void Function(int pid, List<String> argv, bool ended);
