# Changelog

## 0.2.0

- `ToolSpec<O>` is a tool's definition only: its name, description, input
  schema and `concurrent`, and `O`, the type of what a call returns.
  `ToolSpec.run`, `ToolContext`, `ToolImage` and `ToolProcessTap` are removed:
  the code that answers a call, and what a call reports while it runs, belong
  to the airlock, which attaches it through the definition so that it must
  return an `O`.
- The library comment says kit for a host's set of tools.

## 0.1.0

- First release: `ToolSpec`, `ToolContext`, `ToolImage` and `ToolProcessTap`,
  the contract intersyntactic's tools are written against.
