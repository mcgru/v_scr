# v_scr Spec

## Goal

Build `v_scr` as a V (`v0.5.1+`) library that makes shell-like automation readable in V code while preserving explicit types, explicit errors, and predictable runtime semantics.

The target is "Bash in spirit, V in design".

## Core Model

Carry forward the parts of `go_scriptish` that matter most:

- reusable `Pipeline` and `List` sequences
- small steps divided into `sources`, `filters`, `sinks`, `builtins`, and `logic`
- explicit `stdout`, `stderr`, and exit status
- positional arguments and local variables
- the ability to call one sequence from another

Do not treat the project as a shell interpreter.

## Main Types

```v
pub type Step = fn (mut Pipe) !

pub struct Pipe {
pub mut:
    stdin  []u8
    stdout []u8
    stderr []u8
    status int
    cwd    string
    env    map[string]string
    args   []string
    locals map[string]string
    trace  bool
}

pub struct RunResult {}
pub struct Pipeline {}
pub struct List {}
```

## Execution Semantics

### Pipeline

- feed `stdout` of one step into `stdin` of the next step
- stop on fatal runtime error
- stop or branch on non-zero status according to the step or wrapper logic

### List

- execute steps sequentially
- use it for control flow and shell-like orchestration
- do not require pipe-style `stdout -> stdin` chaining between every step

## Error Model

Keep two layers separate.

### V error

Use `!` for:

- invalid regex
- file open failures
- process creation failures
- internal runtime failures

### Shell status

Store shell success or failure in `RunResult.status` and in the active `Pipe.status`.

Use it for:

- command exit code
- shell-style tests
- false conditions

Do not turn every non-zero exit into a V error.

## Process Runtime

Build external process execution on `os.new_process()`.

Need:

- `set_args(...)`
- `set_redirect_stdio()`
- `stdin_write(...)`
- `stdout_slurp()`
- `stderr_slurp()`
- `wait()`

Prefer:

- `exec(cmd string, args ...string) Step`

Allow:

- `sh(line string) Step`

Keep `sh(...)` as convenience sugar only.

## Expansion Model

Support a deliberately small shell-like expansion set:

- `$1 .. $9`
- `$*`
- `$#`
- `$VAR`
- `${VAR}`
- `${!VAR}`

Store locals and env as `map[string]string`.

Resolve in this order:

1. locals
2. args
3. env

Keep globbing opt-in.

## Public API Target

### Constructors

- `new_pipeline(steps ...Step) Pipeline`
- `new_list(steps ...Step) List`
- `exec_pipeline(steps ...Step) !RunResult`
- `exec_list(steps ...Step) !RunResult`

### Core sources

- `echo(input string) Step`
- `echo_args() Step`
- `cat_file(path string) Step`
- `cat_stdin() Step`
- `which(cmd string) Step`
- `list_files(path string) Step`
- `exec(cmd string, args ...string) Step`
- `sh(line string) Step`

### Core filters

- `grep(pattern string) !Step`
- `grep_v(pattern string) !Step`
- `grep_r(pattern string) !Step`
- `sed(expr string) !Step`
- `head(n int) Step`
- `tail(n int) Step`
- `count_lines() Step`
- `count_words() Step`
- `sort() Step`
- `rsort() Step`
- `uniq() Step`
- `trim_whitespace() Step`
- `basename() Step`
- `dirname() Step`
- `strip_extension() Step`
- `swap_extensions(old_ext string, new_ext string) Step`

### Sinks

- `to_stdout() Step`
- `to_stderr() Step`
- `write_to_file(path string) Step`
- `append_to_file(path string) Step`
- `return_(status int) Step`
- `exit_(status int) Step`

### Builtins

- `mkdir(path string, mode u32) Step`
- `rm_file(path string) Step`
- `rm_dir(path string) Step`
- `touch(path string) Step`
- `chmod(path string, mode u32) Step`
- `test_filepath_exists(path string) Step`
- `test_empty() Step`
- `test_not_empty() Step`

### Logic

- `and_(sq SequenceLike) Step`
- `or_(sq SequenceLike) Step`
- `if_(expr Step, body SequenceLike) Step`
- `if_else(expr Step, body SequenceLike, else_body SequenceLike) Step`
- `run_pipeline(pl Pipeline) Step`
- `run_list(ls List) Step`

## MVP 0.1.0

Ship only:

- core runtime
- `Pipeline` and `List`
- process engine
- 12-15 basic steps
- capture helpers
- env and args expansion
- `and_` and `or_`

Leave for later:

- full shell parser
- heredoc
- streaming pipelines
- job control
- full Bash quoting and globbing compatibility

## Recommended Build Order

1. define the public core types
2. implement execution flow and result capture
3. implement process runtime
4. implement MVP sources, filters, sinks, builtins, and logic
5. add examples that translate Bash snippets into `v_scr`
6. add unit and integration tests

## Main Risks

- copying Bash too literally
- mixing shell status with V errors
- assuming one shell platform
- buffering everything in memory forever
