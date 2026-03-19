# module v_scr


## Contents
- [and_](#and_)
- [append_f](#append_f)
- [append_file](#append_file)
- [append_to_file](#append_to_file)
- [args](#args)
- [basename](#basename)
- [cat_file](#cat_file)
- [cat_stdin](#cat_stdin)
- [cd](#cd)
- [chmod](#chmod)
- [count_lines](#count_lines)
- [count_words](#count_words)
- [dirname](#dirname)
- [echo](#echo)
- [echo_args](#echo_args)
- [empty](#empty)
- [env](#env)
- [exec](#exec)
- [exec_list](#exec_list)
- [exec_pipeline](#exec_pipeline)
- [exists](#exists)
- [exit_](#exit_)
- [expand](#expand)
- [expand_all](#expand_all)
- [from_f](#from_f)
- [from_file](#from_file)
- [grep](#grep)
- [grep_p](#grep_p)
- [grep_r](#grep_r)
- [grep_v](#grep_v)
- [group](#group)
- [head](#head)
- [if_](#if_)
- [if_else](#if_else)
- [list_files](#list_files)
- [local_](#local_)
- [ls](#ls)
- [mkdir](#mkdir)
- [new_list](#new_list)
- [new_pipe](#new_pipe)
- [new_pipeline](#new_pipeline)
- [non_empty](#non_empty)
- [or_](#or_)
- [pipe](#pipe)
- [return_](#return_)
- [rm_dir](#rm_dir)
- [rm_file](#rm_file)
- [rsort](#rsort)
- [run_list](#run_list)
- [run_pipeline](#run_pipeline)
- [sed](#sed)
- [set_args](#set_args)
- [set_cwd](#set_cwd)
- [set_env_var](#set_env_var)
- [set_local](#set_local)
- [set_trace](#set_trace)
- [sh](#sh)
- [sort](#sort)
- [strip_extension](#strip_extension)
- [swap_extensions](#swap_extensions)
- [tail](#tail)
- [test_empty](#test_empty)
- [test_filepath_exists](#test_filepath_exists)
- [test_not_empty](#test_not_empty)
- [to_f](#to_f)
- [to_file](#to_file)
- [to_stderr](#to_stderr)
- [to_stdout](#to_stdout)
- [touch](#touch)
- [trim_whitespace](#trim_whitespace)
- [uniq](#uniq)
- [unset_env_var](#unset_env_var)
- [unset_local](#unset_local)
- [which](#which)
- [write_to_file](#write_to_file)
- [Sequence](#Sequence)
- [Step](#Step)
- [List](#List)
  - [exec](#exec)
  - [call](#call)
  - [invoke](#invoke)
  - [run_into](#run_into)
- [Pipe](#Pipe)
  - [result](#result)
- [Pipeline](#Pipeline)
  - [exec](#exec)
  - [call](#call)
  - [invoke](#invoke)
  - [run_into](#run_into)
- [RunResult](#RunResult)
  - [bytes](#bytes)
  - [string](#string)
  - [stderr_string](#stderr_string)
  - [stderr_bytes](#stderr_bytes)
  - [trimmed_string](#trimmed_string)
  - [strings](#strings)
  - [stderr_strings](#stderr_strings)
  - [parse_int](#parse_int)
  - [okay](#okay)
  - [status_code](#status_code)

## and_
```v
fn and_(sequence Sequence) Step
```

and_ runs a sequence only when the current status is zero.

Example
```v

_ := v_scr.and_(v_scr.new_list(v_scr.echo('ok')))

```

[[Return to contents]](#Contents)

## append_f
```v
fn append_f(path string) Step
```

append_f is a short alias for append_to_file.

Example
```v

_ := v_scr.append_f('/tmp/demo.txt')

```

[[Return to contents]](#Contents)

## append_file
```v
fn append_file(path string) Step
```

append_file is a short alias for append_to_file.

Example
```v

_ := v_scr.append_file('/tmp/demo.txt')

```

[[Return to contents]](#Contents)

## append_to_file
```v
fn append_to_file(path string) Step
```

append_to_file creates a step that appends the active stream to a file.

Example
```v

_ := v_scr.append_to_file('/tmp/demo.txt')

```

[[Return to contents]](#Contents)

## args
```v
fn args(args ...string) Step
```

args is a short alias for set_args.

Example
```v

_ := v_scr.args('one', 'two')

```

[[Return to contents]](#Contents)

## basename
```v
fn basename() Step
```

basename creates a step that maps each input line to its base path component.

Example
```v

_ := v_scr.basename()

```

[[Return to contents]](#Contents)

## cat_file
```v
fn cat_file(path string) Step
```

cat_file creates a step that reads a file into the current output stream.

Example
```v

_ := v_scr.cat_file('/tmp/demo.txt')

```

[[Return to contents]](#Contents)

## cat_stdin
```v
fn cat_stdin() Step
```

cat_stdin creates a step that forwards stdin into stdout.

Example
```v

_ := v_scr.cat_stdin()

```

[[Return to contents]](#Contents)

## cd
```v
fn cd(path string) Step
```

cd is a short alias for set_cwd.

Example
```v

_ := v_scr.cd('/tmp')

```

[[Return to contents]](#Contents)

## chmod
```v
fn chmod(path string, mode u32) Step
```

chmod creates a step that changes file permissions.

Example
```v

_ := v_scr.chmod('/tmp/demo.txt', 0o644)

```

[[Return to contents]](#Contents)

## count_lines
```v
fn count_lines() Step
```

count_lines creates a step that counts input lines.

Example
```v

_ := v_scr.count_lines()

```

[[Return to contents]](#Contents)

## count_words
```v
fn count_words() Step
```

count_words creates a step that counts whitespace-delimited words.

Example
```v

_ := v_scr.count_words()

```

[[Return to contents]](#Contents)

## dirname
```v
fn dirname() Step
```

dirname creates a step that maps each input line to its directory component.

Example
```v

_ := v_scr.dirname()

```

[[Return to contents]](#Contents)

## echo
```v
fn echo(input string) Step
```

echo creates a step that writes expanded text to the current output stream.

Example
```v

_ := v_scr.echo('hello')

```

[[Return to contents]](#Contents)

## echo_args
```v
fn echo_args() Step
```

echo_args creates a step that joins positional args with spaces.

Example
```v

_ := v_scr.echo_args()

```

[[Return to contents]](#Contents)

## empty
```v
fn empty() Step
```

empty is a short alias for test_empty.

Example
```v

_ := v_scr.empty()

```

[[Return to contents]](#Contents)

## env
```v
fn env(name string, value string) Step
```

env is a short alias for set_env_var.

Example
```v

_ := v_scr.env('APP_ENV', 'dev')

```

[[Return to contents]](#Contents)

## exec
```v
fn exec(cmd string, args ...string) Step
```

exec creates a step that runs an external command with expanded args.

Example
```v

_ := v_scr.exec('printf', '%s', 'hello')

```

[[Return to contents]](#Contents)

## exec_list
```v
fn exec_list(steps ...Step) !RunResult
```

exec_list is a convenience helper for constructing and running a list.

Example
```v

result := v_scr.exec_list(v_scr.echo('a'), v_scr.echo('b')) or { return }; _ = result

```

[[Return to contents]](#Contents)

## exec_pipeline
```v
fn exec_pipeline(steps ...Step) !RunResult
```

exec_pipeline is a convenience helper for constructing and running a pipeline.

Example
```v

result := v_scr.exec_pipeline(v_scr.echo('a\\nb'), v_scr.count_lines()) or { return }; _ = result

```

[[Return to contents]](#Contents)

## exists
```v
fn exists(path string) Step
```

exists is a short alias for test_filepath_exists.

Example
```v

_ := v_scr.exists('/tmp/demo.txt')

```

[[Return to contents]](#Contents)

## exit_
```v
fn exit_(status int) Step
```

exit_ stops the outer sequence with the provided status.

Example
```v

_ := v_scr.exit_(1)

```

[[Return to contents]](#Contents)

## expand
```v
fn expand(input string, pipe Pipe) string
```

expand resolves shell-like variables against the current pipe context.

Example
```v

_ = v_scr.expand(r'$HOME', v_scr.new_pipe())

```

[[Return to contents]](#Contents)

## expand_all
```v
fn expand_all(values []string, pipe Pipe) []string
```

expand_all resolves shell-like variables for every string in a slice.

Example
```v

_ = v_scr.expand_all([r'$HOME'], v_scr.new_pipe())

```

[[Return to contents]](#Contents)

## from_f
```v
fn from_f(path string) Step
```

from_f is a short alias for cat_file.

Example
```v

_ := v_scr.from_f('/tmp/demo.txt')

```

[[Return to contents]](#Contents)

## from_file
```v
fn from_file(path string) Step
```

from_file is a short alias for cat_file.

Example
```v

_ := v_scr.from_file('/tmp/demo.txt')

```

[[Return to contents]](#Contents)

## grep
```v
fn grep(pattern string) !Step
```

grep creates a substring filter over the current stream.

Example
```v

_ := v_scr.grep('error') or { panic(err) }

```

[[Return to contents]](#Contents)

## grep_p
```v
fn grep_p(args ...string) !Step
```

grep_p creates a shell-like PCRE grep with flags and optional file arguments.

Example
```v

_ := v_scr.grep_p('-in', '^warn', 'app.log') or { panic(err) }

```

[[Return to contents]](#Contents)

## grep_r
```v
fn grep_r(pattern string) !Step
```

grep_r creates a lightweight regex filter over the current stream.

Example
```v

_ := v_scr.grep_r('^warn') or { panic(err) }

```

[[Return to contents]](#Contents)

## grep_v
```v
fn grep_v(pattern string) !Step
```

grep_v creates an inverted substring filter over the current stream.

Example
```v

_ := v_scr.grep_v('debug') or { panic(err) }

```

[[Return to contents]](#Contents)

## group
```v
fn group(steps ...Step) Step
```

group builds an inline nested List step.

Example
```v

_ := v_scr.group(v_scr.echo('a'), v_scr.echo('b'))

```

[[Return to contents]](#Contents)

## head
```v
fn head(n int) Step
```

head creates a step that keeps the first n input lines.

Example
```v

_ := v_scr.head(5)

```

[[Return to contents]](#Contents)

## if_
```v
fn if_(expr Step, body Sequence) Step
```

if_ runs a sequence when the probe step succeeds with zero status.

Example
```v

_ := v_scr.if_(v_scr.non_empty(), v_scr.new_list(v_scr.echo('has input')))

```

[[Return to contents]](#Contents)

## if_else
```v
fn if_else(expr Step, body Sequence, else_body Sequence) Step
```

if_else runs one of two sequences based on the probe step status.

Example
```v

_ := v_scr.if_else(v_scr.non_empty(), v_scr.new_list(v_scr.echo('yes')), v_scr.new_list(v_scr.echo('no')))

```

[[Return to contents]](#Contents)

## list_files
```v
fn list_files(path string) Step
```

list_files creates a step that lists directory entries separated by newlines.

Example
```v

_ := v_scr.list_files('.')

```

[[Return to contents]](#Contents)

## local_
```v
fn local_(name string, value string) Step
```

local_ is a short alias for set_local.

Example
```v

_ := v_scr.local_('name', 'demo')

```

[[Return to contents]](#Contents)

## ls
```v
fn ls(path string) Step
```

ls is a short alias for list_files.

Example
```v

_ := v_scr.ls('.')

```

[[Return to contents]](#Contents)

## mkdir
```v
fn mkdir(path string, mode u32) Step
```

mkdir creates a step that ensures a directory exists.

Example
```v

_ := v_scr.mkdir('/tmp/demo', 0o755)

```

[[Return to contents]](#Contents)

## new_list
```v
fn new_list(steps ...Step) List
```

new_list builds a reusable sequential group of steps.

Example
```v

list := v_scr.new_list(v_scr.echo('a'), v_scr.echo('b')); _ = list

```

[[Return to contents]](#Contents)

## new_pipe
```v
fn new_pipe() Pipe
```

new_pipe creates an empty execution context with zero status and empty env.

Example
```v

pipe := v_scr.new_pipe(); _ = pipe

```

[[Return to contents]](#Contents)

## new_pipeline
```v
fn new_pipeline(steps ...Step) Pipeline
```

new_pipeline builds a reusable streaming sequence.

Example
```v

pipeline := v_scr.new_pipeline(v_scr.echo('a\\nb'), v_scr.count_lines()); _ = pipeline

```

[[Return to contents]](#Contents)

## non_empty
```v
fn non_empty() Step
```

non_empty is a short alias for test_not_empty.

Example
```v

_ := v_scr.non_empty()

```

[[Return to contents]](#Contents)

## or_
```v
fn or_(sequence Sequence) Step
```

or_ runs a sequence only when the current status is non-zero.

Example
```v

_ := v_scr.or_(v_scr.new_list(v_scr.echo('fallback')))

```

[[Return to contents]](#Contents)

## pipe
```v
fn pipe(steps ...Step) Step
```

pipe builds an inline nested Pipeline step.

Example
```v

_ := v_scr.pipe(v_scr.echo('a\\nb'), v_scr.count_lines())

```

[[Return to contents]](#Contents)

## return_
```v
fn return_(status int) Step
```

return_ stops the current sequence with the provided status.

Example
```v

_ := v_scr.return_(1)

```

[[Return to contents]](#Contents)

## rm_dir
```v
fn rm_dir(path string) Step
```

rm_dir creates a step that removes a directory tree if it exists.

Example
```v

_ := v_scr.rm_dir('/tmp/demo-dir')

```

[[Return to contents]](#Contents)

## rm_file
```v
fn rm_file(path string) Step
```

rm_file creates a step that removes a file if it exists.

Example
```v

_ := v_scr.rm_file('/tmp/demo.txt')

```

[[Return to contents]](#Contents)

## rsort
```v
fn rsort() Step
```

rsort creates a step that sorts lines in descending order.

Example
```v

_ := v_scr.rsort()

```

[[Return to contents]](#Contents)

## run_list
```v
fn run_list(list List) Step
```

run_list wraps a List so it can be used as a Step.

Example
```v

_ := v_scr.run_list(v_scr.new_list(v_scr.echo('a'), v_scr.echo('b')))

```

[[Return to contents]](#Contents)

## run_pipeline
```v
fn run_pipeline(pipeline Pipeline) Step
```

run_pipeline wraps a Pipeline so it can be used as a Step.

Example
```v

_ := v_scr.run_pipeline(v_scr.new_pipeline(v_scr.echo('a\\nb'), v_scr.count_lines()))

```

[[Return to contents]](#Contents)

## sed
```v
fn sed(args ...string) !Step
```

sed creates a step that delegates to the external `sed` command.

Example
```v

_ := v_scr.sed('s/a/A/g') or { panic(err) }

```

[[Return to contents]](#Contents)

## set_args
```v
fn set_args(args ...string) Step
```

set_args creates a step that replaces positional args for the current sequence.

Example
```v

_ := v_scr.set_args('one', 'two')

```

[[Return to contents]](#Contents)

## set_cwd
```v
fn set_cwd(path string) Step
```

set_cwd creates a step that changes the working directory for later process steps.

Example
```v

_ := v_scr.set_cwd('/tmp')

```

[[Return to contents]](#Contents)

## set_env_var
```v
fn set_env_var(name string, value string) Step
```

set_env_var creates a step that sets or updates an environment variable.

Example
```v

_ := v_scr.set_env_var('APP_ENV', 'dev')

```

[[Return to contents]](#Contents)

## set_local
```v
fn set_local(name string, value string) Step
```

set_local creates a step that sets a local shell-like variable.

Example
```v

_ := v_scr.set_local('name', 'demo')

```

[[Return to contents]](#Contents)

## set_trace
```v
fn set_trace(enabled bool) Step
```

set_trace creates a step that enables or disables lightweight process tracing.

Example
```v

_ := v_scr.set_trace(true)

```

[[Return to contents]](#Contents)

## sh
```v
fn sh(line string) Step
```

sh creates a step that runs a shell command line after expansion.

Example
```v

_ := v_scr.sh('printf "%s" "hello"')

```

[[Return to contents]](#Contents)

## sort
```v
fn sort() Step
```

sort creates a step that sorts lines in ascending order.

Example
```v

_ := v_scr.sort()

```

[[Return to contents]](#Contents)

## strip_extension
```v
fn strip_extension() Step
```

strip_extension creates a step that removes the final file extension from each line.

Example
```v

_ := v_scr.strip_extension()

```

[[Return to contents]](#Contents)

## swap_extensions
```v
fn swap_extensions(old_ext string, new_ext string) Step
```

swap_extensions creates a step that replaces one extension with another.

Example
```v

_ := v_scr.swap_extensions('.txt', '.md')

```

[[Return to contents]](#Contents)

## tail
```v
fn tail(n int) Step
```

tail creates a step that keeps the last n input lines.

Example
```v

_ := v_scr.tail(5)

```

[[Return to contents]](#Contents)

## test_empty
```v
fn test_empty() Step
```

test_empty creates a step that succeeds when the active stream is empty.

Example
```v

_ := v_scr.test_empty()

```

[[Return to contents]](#Contents)

## test_filepath_exists
```v
fn test_filepath_exists(path string) Step
```

test_filepath_exists creates a step that succeeds when the path exists.

Example
```v

_ := v_scr.test_filepath_exists('/tmp/demo.txt')

```

[[Return to contents]](#Contents)

## test_not_empty
```v
fn test_not_empty() Step
```

test_not_empty creates a step that succeeds when the active stream is not empty.

Example
```v

_ := v_scr.test_not_empty()

```

[[Return to contents]](#Contents)

## to_f
```v
fn to_f(path string) Step
```

to_f is a short alias for write_to_file.

Example
```v

_ := v_scr.to_f('/tmp/demo.txt')

```

[[Return to contents]](#Contents)

## to_file
```v
fn to_file(path string) Step
```

to_file is a short alias for write_to_file.

Example
```v

_ := v_scr.to_file('/tmp/demo.txt')

```

[[Return to contents]](#Contents)

## to_stderr
```v
fn to_stderr() Step
```

to_stderr creates a step that prints the active stream to stderr.

Example
```v

_ := v_scr.to_stderr()

```

[[Return to contents]](#Contents)

## to_stdout
```v
fn to_stdout() Step
```

to_stdout creates a step that prints the active stream to stdout.

Example
```v

_ := v_scr.to_stdout()

```

[[Return to contents]](#Contents)

## touch
```v
fn touch(path string) Step
```

touch creates a step that creates an empty file when it does not exist.

Example
```v

_ := v_scr.touch('/tmp/demo.txt')

```

[[Return to contents]](#Contents)

## trim_whitespace
```v
fn trim_whitespace() Step
```

trim_whitespace creates a step that trims leading and trailing whitespace.

Example
```v

_ := v_scr.trim_whitespace()

```

[[Return to contents]](#Contents)

## uniq
```v
fn uniq() Step
```

uniq creates a step that removes duplicate lines while preserving order.

Example
```v

_ := v_scr.uniq()

```

[[Return to contents]](#Contents)

## unset_env_var
```v
fn unset_env_var(name string) Step
```

unset_env_var creates a step that removes an environment variable override.

Example
```v

_ := v_scr.unset_env_var('APP_ENV')

```

[[Return to contents]](#Contents)

## unset_local
```v
fn unset_local(name string) Step
```

unset_local creates a step that removes a local shell-like variable.

Example
```v

_ := v_scr.unset_local('name')

```

[[Return to contents]](#Contents)

## which
```v
fn which(cmd string) Step
```

which creates a step that resolves an executable from PATH.

Example
```v

_ := v_scr.which('v')

```

[[Return to contents]](#Contents)

## write_to_file
```v
fn write_to_file(path string) Step
```

write_to_file creates a step that writes the active stream to a file.

Example
```v

_ := v_scr.write_to_file('/tmp/demo.txt')

```

[[Return to contents]](#Contents)

## Sequence
```v
interface Sequence {
	exec() !RunResult
	run_into(mut pipe Pipe) !RunResult
}
```

Sequence is a reusable ordered collection of steps such as Pipeline or List.

Example
```v

sequence := v_scr.new_pipeline(v_scr.echo('hello')); _ := sequence

```

[[Return to contents]](#Contents)

## Step
```v
type Step = fn (mut Pipe) !
```

Step is a single executable unit that mutates the current Pipe state.

Example
```v

step := v_scr.echo('hello'); _ := step

```

[[Return to contents]](#Contents)

## List
```v
struct List {
pub:
	steps []Step
}
```

List runs steps sequentially while accumulating shared stdout and stderr.

Example
```v

list := v_scr.new_list(v_scr.echo('a'), v_scr.echo('b')); _ = list

```

[[Return to contents]](#Contents)

## exec
```v
fn (list List) exec() !RunResult
```

exec runs the list in a fresh Pipe.

Example
```v

result := v_scr.new_list(v_scr.echo('a'), v_scr.echo('b')).exec() or { return }; _ = result

```

[[Return to contents]](#Contents)

## call
```v
fn (list List) call(args ...string) !RunResult
```

call runs the list in a fresh Pipe with positional args preset.

Example
```v

result := v_scr.new_list(v_scr.echo('$1')).call('demo') or { return }; _ = result

```

[[Return to contents]](#Contents)

## invoke
```v
fn (list List) invoke(args ...string) Step
```

invoke wraps the list as a step and temporarily overrides positional args.

Example
```v

nested := v_scr.new_list(v_scr.echo('$1')).invoke('demo'); _ := nested

```

[[Return to contents]](#Contents)

## run_into
```v
fn (list List) run_into(mut pipe Pipe) !RunResult
```

run_into executes the list inside an existing Pipe context.

Example
```v

mut pipe := v_scr.new_pipe(); result := v_scr.new_list(v_scr.echo('ok')).run_into(mut pipe) or { return }; _ = result

```

[[Return to contents]](#Contents)

## Pipe
```v
struct Pipe {
pub mut:
	stdin     []u8
	stdout    []u8
	stderr    []u8
	status    int
	cwd       string
	env       map[string]string
	args      []string
	locals    map[string]string
	trace     bool
	stopped   bool
	stop_kind StopKind
}
```

Pipe carries the mutable execution state shared by steps in a sequence.

Example
```v

mut pipe := v_scr.new_pipe(); _ = pipe

```

[[Return to contents]](#Contents)

## result
```v
fn (p Pipe) result() RunResult
```

result snapshots the current pipe state into a RunResult value.

Example
```v

mut pipe := v_scr.new_pipe(); result := pipe.result(); _ = result

```

[[Return to contents]](#Contents)

## Pipeline
```v
struct Pipeline {
pub:
	steps []Step
}
```

Pipeline connects stdout of each step to stdin of the next one.

Example
```v

pipeline := v_scr.new_pipeline(v_scr.echo('a\\nb'), v_scr.count_lines()); _ = pipeline

```

[[Return to contents]](#Contents)

## exec
```v
fn (pipeline Pipeline) exec() !RunResult
```

exec runs the pipeline in a fresh Pipe.

Example
```v

result := v_scr.new_pipeline(v_scr.echo('a\\nb'), v_scr.count_lines()).exec() or { return }; _ = result

```

[[Return to contents]](#Contents)

## call
```v
fn (pipeline Pipeline) call(args ...string) !RunResult
```

call runs the pipeline in a fresh Pipe with positional args preset.

Example
```v

result := v_scr.new_pipeline(v_scr.echo('$1')).call('demo') or { return }; _ = result

```

[[Return to contents]](#Contents)

## invoke
```v
fn (pipeline Pipeline) invoke(args ...string) Step
```

invoke wraps the pipeline as a step and temporarily overrides positional args.

Example
```v

nested := v_scr.new_pipeline(v_scr.echo('$1')).invoke('demo'); _ := nested

```

[[Return to contents]](#Contents)

## run_into
```v
fn (pipeline Pipeline) run_into(mut pipe Pipe) !RunResult
```

run_into executes the pipeline inside an existing Pipe context.

Example
```v

mut pipe := v_scr.new_pipe(); result := v_scr.new_pipeline(v_scr.echo('ok')).run_into(mut pipe) or { return }; _ = result

```

[[Return to contents]](#Contents)

## RunResult
```v
struct RunResult {
pub:
	stdout []u8
	stderr []u8
	status int
}
```

RunResult is the immutable output of executing a sequence.

Example
```v

result := v_scr.exec_pipeline(v_scr.echo('42')) or { return }; _ = result

```

[[Return to contents]](#Contents)

## bytes
```v
fn (result RunResult) bytes() []u8
```

bytes returns stdout as raw bytes.

Example
```v

result := v_scr.exec_pipeline(v_scr.echo('hi')) or { return }; _ = result.bytes()

```

[[Return to contents]](#Contents)

## string
```v
fn (result RunResult) string() string
```

string returns stdout as a string.

Example
```v

result := v_scr.exec_pipeline(v_scr.echo('hi')) or { return }; _ = result.string()

```

[[Return to contents]](#Contents)

## stderr_string
```v
fn (result RunResult) stderr_string() string
```

stderr_string returns stderr as a string.

Example
```v

result := v_scr.exec_pipeline(v_scr.to_stderr()) or { return }; _ = result.stderr_string()

```

[[Return to contents]](#Contents)

## stderr_bytes
```v
fn (result RunResult) stderr_bytes() []u8
```

stderr_bytes returns stderr as raw bytes.

Example
```v

result := v_scr.exec_pipeline(v_scr.to_stderr()) or { return }; _ = result.stderr_bytes()

```

[[Return to contents]](#Contents)

## trimmed_string
```v
fn (result RunResult) trimmed_string() string
```

trimmed_string returns stdout trimmed of leading and trailing whitespace.

Example
```v

result := v_scr.exec_pipeline(v_scr.echo('  hi  '), v_scr.trim_whitespace()) or { return }; _ = result.trimmed_string()

```

[[Return to contents]](#Contents)

## strings
```v
fn (result RunResult) strings() []string
```

strings splits trimmed stdout into lines.

Example
```v

result := v_scr.exec_pipeline(v_scr.echo('a\\nb')) or { return }; _ = result.strings()

```

[[Return to contents]](#Contents)

## stderr_strings
```v
fn (result RunResult) stderr_strings() []string
```

stderr_strings splits trimmed stderr into lines.

Example
```v

result := v_scr.exec_pipeline(v_scr.echo('warn'), v_scr.to_stderr()) or { return }; _ = result.stderr_strings()

```

[[Return to contents]](#Contents)

## parse_int
```v
fn (result RunResult) parse_int() !int
```

parse_int parses trimmed stdout as an integer.

Example
```v

result := v_scr.exec_pipeline(v_scr.echo('42')) or { return }; _ := result.parse_int() or { return }

```

[[Return to contents]](#Contents)

## okay
```v
fn (result RunResult) okay() bool
```

okay reports whether the exit status is zero.

Example
```v

result := v_scr.exec_pipeline(v_scr.echo('ok')) or { return }; _ = result.okay()

```

[[Return to contents]](#Contents)

## status_code
```v
fn (result RunResult) status_code() int
```

status_code returns the final exit status.

Example
```v

result := v_scr.exec_pipeline(v_scr.echo('ok')) or { return }; _ = result.status_code()

```

[[Return to contents]](#Contents)

#### Powered by vdoc. Generated on: 19 Mar 2026 04:16:07
