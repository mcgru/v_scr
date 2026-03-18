# v_scr

`v_scr` is a shell-like scripting library for V (`v0.5.1+`).

The goal is to make automation code read closer to Bash while keeping V's explicit types, explicit errors, and predictable runtime semantics.

## Status

This repository currently contains a working early implementation:

- core runtime types
- `Pipeline` and `List`
- result helpers
- process execution on top of `os.new_process()`
- variable expansion for args, locals, and env
- a first batch of sources, filters, sinks, builtins, and logic helpers

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

For frequent file operations there are short aliases too:

- `from_file(...)` / `from_f(...)` -> `cat_file(...)`
- `to_file(...)` / `to_f(...)` -> `write_to_file(...)`
- `append_file(...)` / `append_f(...)` -> `append_to_file(...)`
- `ls(...)` -> `list_files(...)`
- `exists(...)` -> `test_filepath_exists(...)`

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
    v_scr.set_env_var('APP_NAME', 'demo-app'),
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
    v_scr.pipe(
        v_scr.echo('release: demo-app\n'),
        v_scr.to_f(target),
    ),
    v_scr.echo('written to ${target}\n'),
).exec()!
```

See the runnable examples in `examples/basic_pipeline.v`, `examples/bash_to_vscr.v`, `examples/deploy.vsh`, and `examples/list_vs_pipeline.v`.

## Next steps

- expand file and process integration coverage
- add more shell-like filters and convenience helpers
- refine sequence semantics and release the first `0.1.x` package

See `project.md` for the project plan.
