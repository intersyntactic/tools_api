# Changelog

## 0.2.0

- `ToolSpec<I, O>` is a tool's definition only: its name, description,
  `input` and `concurrent`, and the types of what a call takes, `I`, and
  returns, `O`. `ToolSpec.run`, `ToolContext`, `ToolImage` and
  `ToolProcessTap` are removed: the code that answers a call, and what a call
  reports while it runs, belong to the airlock, which attaches it through the
  definition so that it must take an `I` and return an `O`.
- `Input<I>`, `Field<T>` and `Schema<T>` replace the hand-written
  `inputSchema` map: one description gives both the JSON Schema the model is
  shown and the reader that turns what it sent into an `I`, with every
  constraint the schema shows checked by the reader. `inputSchema` is now
  `input.schema`.
- `Output<O>` turns the `O` a call returns into the text of its tool result,
  once per tool; `Output.text` is for an answer that is already text. A
  failed call has no `O`: whoever runs the call reports it.
- The library comment says kit for a host's set of tools.

## 0.1.0

- First release: `ToolSpec`, `ToolContext`, `ToolImage` and `ToolProcessTap`,
  the contract intersyntactic's tools are written against.
