# v_scr

`v_scr` is a shell-like scripting library for V (`v0.5.1+`).

The goal is to make automation code read closer to Bash while keeping V's explicit types, explicit errors, and predictable runtime semantics.

## Status

This repository currently contains a working `0.1.x`-level MVP:

- core runtime types
- `Pipeline` and `List`
- result helpers
- process execution on top of `os.new_process()`
- variable expansion for args, locals, and env
- a first batch of sources, filters, sinks, builtins, and logic helpers
- runnable examples and tests for process, file, and nested-sequence semantics

## Packaging notes

The package is already structured as a normal V module with `v.mod`, runnable examples, and tests.

The next release-facing step is packaging polish for VPM publication, not core runtime work.

## API stability

For `0.1.x`, treat the long names as canonical API:

- `cat_file`, `write_to_file`, `append_to_file`
- `set_args`, `set_env_var`, `set_local`, `set_cwd`
- `run_pipeline`, `run_list`

Treat the short names as stable scripting aliases:

- `from_file`, `from_f`, `to_file`, `to_f`, `append_file`, `append_f`
- `args`, `env`, `local_`, `cd`
- `pipe`, `group`

The long names optimize for clarity in library code.

The short names optimize for terseness in `.vsh` scripts and shell-like automation snippets.

## Sequence model

`v_scr` has two different sequence types on purpose:

- `Pipeline`: pass the byte stream from one step to the next step
- `List`: orchestrate multiple steps and accumulate their resulting `stdout`/`stderr`

### Use `Pipeline` when

- the next step needs the previous step's output as input
- you are doing text transformation
- the last step is a sink like `write_to_file()` or `append_to_file()`
- you want shell-like `cmd1 | cmd2 | cmd3` behavior

### Use `List` when

- you are sequencing independent actions
- you are setting args, env, cwd, locals, or trace flags
- you are combining control-flow helpers like `and_`, `or_`, `if_`, `if_else`
- you want the combined `stdout`/`stderr` of several top-level steps

### Rule of thumb

If you catch yourself writing:

```v
v_scr.new_list(
    v_scr.echo('hello'),
    v_scr.write_to_file('/tmp/demo.txt'),
)
```

that should usually be:

```v
v_scr.new_list(
    v_scr.pipe(
        v_scr.echo('hello'),
        v_scr.write_to_file('/tmp/demo.txt'),
    ),
)
```

The `List` orchestrates. The `Pipeline` moves bytes.

For nested orchestration helpers:

- `pipe(...)` is shorthand for `run_pipeline(new_pipeline(...))`
- `group(...)` is shorthand for `run_list(new_list(...))`

Short aliases for files, context, and tests are listed in the cheatsheet below.

## API cheatsheet

Use the long names when you want maximum explicitness in library code.

Use the short names when you are writing shell-like scripts and the intent is already obvious from context.

| Long name | Short name | Typical use |
| --- | --- | --- |
| `cat_file(path)` | `from_file(path)`, `from_f(path)` | Read a file into a pipeline |
| `write_to_file(path)` | `to_file(path)`, `to_f(path)` | Final sink in a pipeline |
| `append_to_file(path)` | `append_file(path)`, `append_f(path)` | Append pipeline output to a file |
| `list_files(path)` | `ls(path)` | Small shell-like directory listing |
| `test_filepath_exists(path)` | `exists(path)` | Guard/check before branching |
| `set_args(...)` | `args(...)` | Positional args for a sequence |
| `set_env_var(name, value)` | `env(name, value)` | Environment setup before `exec()` / `sh()` |
| `set_local(name, value)` | `local_(name, value)` | Local shell-like variables |
| `set_cwd(path)` | `cd(path)` | Change working directory for later steps |
| `test_empty()` | `empty()` | Assert/check empty active stream |
| `test_not_empty()` | `non_empty()` | Assert/check non-empty active stream |
| `run_pipeline(new_pipeline(...))` | `pipe(...)` | Inline nested pipeline |
| `run_list(new_list(...))` | `group(...)` | Inline nested list/orchestration |

## Examples

### Basic pipeline

```v
import v_scr

result := v_scr.new_pipeline(
    v_scr.echo('alpha\nbeta\ngamma\n'),
    v_scr.grep('a')!,
    v_scr.count_lines(),
).exec()!

assert result.trimmed_string() == '3'
```

### List for orchestration

```v
import v_scr

result := v_scr.new_list(
    v_scr.env('APP_NAME', 'demo-app'),
    v_scr.sh('printf "deploying %s\n" "\$APP_NAME"'),
).exec()!

print(result.string())
```

### Mix `List` and `Pipeline`

```v
import os
import v_scr

target := os.join_path(os.vtmp_dir(), 'v_scr-demo.txt')
result := v_scr.new_list(
    v_scr.cd(os.vtmp_dir()),
    v_scr.pipe(
        v_scr.echo('release: demo-app\n'),
        v_scr.to_f(target),
    ),
    v_scr.echo('written to ${target}\n'),
).exec()!
```

### Reusable sequences with `call()` and `invoke()`

```v
import v_scr

greeter := v_scr.new_list(
    v_scr.local_('name', '\$1'),
    v_scr.echo('hello, \$name'),
)

direct := greeter.call('direct')!
nested := v_scr.new_list(
    v_scr.echo('before|'),
    greeter.invoke('nested'),
    v_scr.echo('|after'),
).exec()!
```

See the runnable examples in `examples/basic_pipeline.v`, `examples/bash_to_vscr.v`, `examples/deploy.vsh`, `examples/list_vs_pipeline.v`, and `examples/call_and_invoke.v`.

## Next steps

- broaden integration coverage on more platforms
- add more shell-like filters and convenience helpers where they clearly improve readability
- prepare packaging and VPM-facing release polish

See `project.md` for the project plan.
