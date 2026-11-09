/// What a call returns, as the model is shown it: [forModel] turns an [O]
/// into the text of the call's tool result.
///
/// One description per tool, as `Input` is for what a call takes, so every
/// answer of one tool reaches the model the same way. Only an answer is
/// rendered here: a call that failed has no [O], and whoever runs the call
/// reports its failure itself.
final class Output<O> {
  const Output(this._forModel);

  final String Function(O value) _forModel;

  /// [value] as the text of the call's tool result.
  String forModel(O value) => _forModel(value);

  /// For a tool whose answer is already the text: as it is.
  static const text = Output<String>(_asItIs);
}

String _asItIs(String text) => text;
