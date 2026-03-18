---
name: "v-scr-builder"
description: "Design and implement the `v_scr` library: a V (`v0.5.1+`) shell-like DSL inspired by `go_scriptish` for pipelines, lists, process execution, expansion, and Bash-style ergonomics. Use when Codex needs to scaffold, extend, refactor, review, or document `v_scr`; translate Bash or `go_scriptish` patterns into idiomatic V; or make decisions about `Pipe`, `Pipeline`, `List`, `RunResult`, process execution, shell-status semantics, and variable expansion."
---

# v_scr Builder

## Overview

Treat `v_scr` as a typed V library for shell-like scripting.

Preserve Bash ergonomics, but do not build a Bash interpreter.

Read [references/v-scr-spec.md](references/v-scr-spec.md) before changing architecture, public API, or execution semantics.

## Workflow

1. Read `references/v-scr-spec.md`.
2. Inspect the current repository state before changing design or code.
3. Implement from the inside out:
   - core runtime
   - process engine
   - filters, sinks, builtins, logic
   - examples and tests
4. Keep API snake_case and V-idiomatic.
5. Validate behavior with focused tests after each substantial change.

## Core Rules

- Keep `Pipeline` and `List` as separate concepts.
- Model shell state explicitly in `Pipe`.
- Keep V-errors separate from shell status codes.
- Prefer `exec(cmd, args ...string)` as the primary external-process API.
- Keep `sh(line string)` as convenience sugar, not the foundation.
- Build process execution on `os.new_process()`, not on `os.execute()`.
- Keep expansion intentionally small: positional args, locals, env, basic `${...}` forms.
- Treat globbing as opt-in functionality, not automatic behavior.
- Preserve reuse: allow calling one sequence from another.

## Design Guardrails

- Do not add a full Bash parser.
- Do not add full quoting or expansion compatibility.
- Do not add job control to the first iterations.
- Do not collapse shell status into V exceptions.
- Do not overfit the API to one platform's shell behavior.

## Implementation Priorities

- Start with `Step`, `Pipe`, `RunResult`, `Pipeline`, and `List`.
- Add capture helpers such as `string()`, `trimmed_string()`, `parse_int()`, and `okay()`.
- Add process execution with `stdout`, `stderr`, `stdin`, `cwd`, `env`, and exit-code capture.
- Add the MVP commands from the spec before broader convenience helpers.
- Add examples that translate small Bash snippets into `v_scr`.

## Validation

- Test pure filters with unit tests.
- Test process execution and filesystem helpers with integration tests.
- Validate both success paths and non-zero shell statuses.
- Preserve cross-platform awareness for paths, quoting, and command invocation.

## References

- Read [references/v-scr-spec.md](references/v-scr-spec.md) for the current architecture, API target, MVP scope, and non-goals.
