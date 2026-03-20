# v_scr

`v_scr` is a shell-like scripting library for V (`v0.5.1+`).

The goal is to make automation code read closer to Bash while keeping V's explicit types, explicit errors, and predictable runtime semantics.

## Status

This repository contains a working `0.2.0` release with:

- core runtime types
- `Pipeline` and `List`
- result helpers
- process execution on top of `os.new_process()`
- variable expansion for args, locals, and env with enhanced parameter expansion
- sources, filters, sinks, builtins, and logic helpers
- file utilities: `cp`, `mv`, `ln`, `readlink`, `realpath`
- streaming helpers for large file processing
- runnable examples and tests for process, file, and nested-sequence semantics

## What's New in v0.2.0

**File Utilities:**
- `cp(src, dst)` - Copy files and directories with `-r`, `-f`, `-q` flags
- `mv(src, dst)` - Move/rename files with `-f`, `-q` flags
- `ln(args...)` - Create hard and symbolic links with `-s`, `-f`, `-q` flags
- `readlink(args...)` - Read symbolic link targets
- `realpath(args...)` - Get canonical absolute paths

**Enhanced Parameter Expansion:**
- `${VAR:-default}` - Use default if VAR is unset or empty
- `${VAR:+value}` - Use value if VAR is set
- `${#VAR}` - String length
- `${VAR^^}` - Convert to uppercase
- `${VAR,,}` - Convert to lowercase
- `${VAR:offset}` - Substring from offset
- `${VAR:offset:len}` - Substring with length

**Streaming Support:**
- `stream_lines(path, processor)` - Process large files line by line
- `stream_lines_filtered(path, predicate)` - Filter lines from large files
- `head_stream(n, path)` - Efficiently read first n lines
- `tail_stream(n, path)` - Efficiently read last n lines
- `grep_stream(pattern, path)` - Stream grep for large files
- `wc_stream(path)` - Count lines, words, bytes

## Packaging notes

The package is structured as a normal V module with `v.mod`, runnable examples, and tests.

Ready for VPM publication.

## API stability

For `0.2.x`, treat the long names as canonical API:

- `cat`, `stdout`, `stderr`, `write_to_file`, `append_to_file`
- `rm`, `rmdir`, `pwd`
- `cp`, `mv`, `ln`, `readlink`, `realpath`
- `set_args`, `set_env_var`, `set_local`, `set_cwd`
- `run_pipeline`, `run_list`

Treat the short names as stable scripting aliases:

- `cat_file`, `cat_stdin`, `from_file`, `from_f`
- `to_stdout`, `to_stderr`, `to_file`, `to_f`, `append_file`, `append_f`
- `rm_file`, `rm_dir`, `cp_file`, `mv_file`
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
| `grep_r(pattern)` | - | Lightweight regex filter over the current stream |
| `grep_r_v(pattern)` | - | Inverted lightweight regex filter |
| `grep_p(args...)` | - | Shell-like PCRE grep with flags and optional files |
| `grep_p_v(args...)` | - | Inverted shell-like PCRE grep |
| `cat(args...)` | `cat_file(path)`, `cat_stdin()`, `from_file(path)`, `from_f(path)` | Read a file, or pass stdin through when called without args |
| `write_to_file(path)` | `to_file(path)`, `to_f(path)` | Final sink in a pipeline |
| `stdout(args...)` | `to_stdout()` | Print the active stream, overwrite a file, discard to `os.path_devnull`, or redirect to `os.stderr()` |
| `stdout_a(path)` | - | Append the active stream to a file |
| `stderr(args...)` | `to_stderr()` | Print the active stream to stderr, overwrite a file, discard to `os.path_devnull`, or redirect to `os.stdout()` |
| `stderr_a(path)` | - | Append the active stream to a file while keeping stderr semantics |
| `append_to_file(path)` | `append_file(path)`, `append_f(path)` | Append pipeline output to a file |
| `list_files(args...)` | `ls(args...)` | Small shell-like directory listing |
| `ls_l(args...)` | - | Long-format directory listing via `ls -l` |
| `test_filepath_exists(path)` | `exists(path)` | Guard/check before branching |
| `rm(args...)` | `rm_file(path)` | Remove files, and directories with `-r` |
| `rmdir(args...)` | `rm_dir(path)` | Remove directories, with `-r`, `-f`, `-q` flags |
| `cp(args...)` | `cp_file(src, dst)` | Copy files, with `-r`, `-f`, `-q` flags |
| `mv(args...)` | `mv_file(src, dst)` | Move/rename files, with `-f`, `-q` flags |
| `ln(args...)` | - | Create links, with `-s`, `-f`, `-q` flags |
| `readlink(args...)` | - | Read symbolic link targets |
| `realpath(args...)` | - | Get canonical absolute path |
| `pwd()` | - | Emit the current pipe working directory |
| `set_args(...)` | `args(...)` | Positional args for a sequence |
| `set_env_var(name, value)` | `env(name, value)` | Environment setup before `exec()` / `sh()` |
| `set_local(name, value)` | `local_(name, value)` | Local shell-like variables |
| `set_cwd(path)` | `cd(path)` | Change working directory for later steps |
| `set_trace(bool)` | `unset_trace()` | Enable or disable process tracing |
| `test_empty()` | `empty()` | Assert/check empty active stream |
| `test_not_empty()` | `non_empty()` | Assert/check non-empty active stream |
| `sed(args...)` | `sed_r(args...)`, `sed_r_z(args...)` | Run GNU sed, optionally with `-r` or `-r -z` |
| `run_pipeline(new_pipeline(...))` | `pipe(...)` | Inline nested pipeline |
| `run_list(new_list(...))` | `group(...)` | Inline nested list/orchestration |
| `stream_lines(path, proc)` | - | Process large files line by line |
| `stream_lines_filtered(path, pred)` | - | Filter lines from large files |
| `head_stream(n, path)` | - | Efficiently read first n lines |
| `tail_stream(n, path)` | - | Efficiently read last n lines |
| `grep_stream(pattern, path)` | - | Stream grep for large files |
| `wc_stream(path)` | - | Count lines, words, bytes |

## Examples

### Basic pipeline

```v
import v_scr

result := v_scr.new_pipeline(
    v_scr.echo('alpha\nbeta\ngamma\n'),
    v_scr.grep_r('^a.*')!,
    v_scr.count_lines(),
).exec()!

assert result.trimmed_string() == '2'
```

### Regex filters: `grep_r` vs `grep_p`

Use `grep_r(pattern)` for the simple typed regex filter over the current stream.

Use `grep_r_v(pattern)` for the inverted typed regex case.

Use `grep_p(args...)` when you want shell-like flags such as `-i`, `-n`, `-c`, `-q`, or when you want to match against files directly.

Use `grep_p_v(args...)` for the inverted PCRE case.

```v
import v_scr

stream_result := v_scr.new_pipeline(
    v_scr.echo('warn\nWarning\n'),
    v_scr.grep_r('^warn')!,
).exec()!

inverse_stream_result := v_scr.new_pipeline(
    v_scr.echo('warn\ninfo\n'),
    v_scr.grep_r_v('^warn')!,
).exec()!

pcre_result := v_scr.new_list(
    v_scr.grep_p('-in', '^warn', 'app.log')!,
).exec()!
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
        v_scr.stdout(target),
    ),
    v_scr.echo('written to ${target}\n'),
).exec()!
```

### Stream redirection targets

`stdout(os.stderr())` redirects the active stream into the stderr channel.

`stderr(os.stdout())` merges the active stream into stdout.

`stdout(os.path_devnull)` and `stderr(os.path_devnull)` discard output.

### `head()` and `tail()` with negative values

`head(-n)` keeps all but the last `n` lines.

`tail(-n)` skips the first `n` lines.

```v
import v_scr

result := v_scr.new_pipeline(
    v_scr.echo('one\ntwo\nthree\nfour\n'),
    v_scr.head(-1),
).exec()!

assert result.trimmed_string() == 'one\ntwo\nthree'
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
