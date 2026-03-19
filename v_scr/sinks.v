module v_scr

import os

type OutputArg = bool | string

// stdout creates a step that prints the active stream, or writes/appends it to a file.
// Example: _ := v_scr.stdout('/tmp/demo.txt', false)
pub fn stdout(args ...OutputArg) Step {
    path, append := parse_output_args(args)
    return fn [path, append] (mut pipe Pipe) ! {
        data := active_stream(pipe)
        if path == '' {
            print(data.bytestr())
            pipe.status = 0
            return
        }
        write_stream_to_file(expand(path, pipe), data, append)!
        pipe.status = 0
    }
}

// to_stdout is a compatibility alias for stdout().
// Example: _ := v_scr.to_stdout()
pub fn to_stdout() Step {
    return stdout()
}

// stderr creates a step that prints the active stream to stderr, or writes/appends it to a file while retaining stderr capture.
// Example: _ := v_scr.stderr('/tmp/demo.err')
pub fn stderr(args ...OutputArg) Step {
    path, append := parse_output_args(args)
    return fn [path, append] (mut pipe Pipe) ! {
        data := active_stream(pipe)
        if path == '' {
            eprint(data.bytestr())
        } else {
            write_stream_to_file(expand(path, pipe), data, append)!
        }
        pipe.stderr << data
        pipe.stdout = []u8{}
        pipe.status = 0
    }
}

// to_stderr is a compatibility alias for stderr().
// Example: _ := v_scr.to_stderr()
pub fn to_stderr() Step {
    return stderr()
}

// write_to_file creates a step that writes the active stream to a file.
// Example: _ := v_scr.write_to_file('/tmp/demo.txt')
pub fn write_to_file(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        os.write_file(expand(path, pipe), active_stream(pipe).bytestr())!
        pipe.status = 0
    }
}

// to_file is a short alias for write_to_file.
// Example: _ := v_scr.to_file('/tmp/demo.txt')
pub fn to_file(path string) Step {
    return write_to_file(path)
}

// to_f is a short alias for write_to_file.
// Example: _ := v_scr.to_f('/tmp/demo.txt')
pub fn to_f(path string) Step {
    return write_to_file(path)
}

// append_to_file creates a step that appends the active stream to a file.
// Example: _ := v_scr.append_to_file('/tmp/demo.txt')
pub fn append_to_file(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        expanded := expand(path, pipe)
        existing := os.read_file(expanded) or { '' }
        os.write_file(expanded, existing + active_stream(pipe).bytestr())!
        pipe.status = 0
    }
}

// append_file is a short alias for append_to_file.
// Example: _ := v_scr.append_file('/tmp/demo.txt')
pub fn append_file(path string) Step {
    return append_to_file(path)
}

// append_f is a short alias for append_to_file.
// Example: _ := v_scr.append_f('/tmp/demo.txt')
pub fn append_f(path string) Step {
    return append_to_file(path)
}

// return_ stops the current sequence with the provided status.
// Example: _ := v_scr.return_(1)
pub fn return_(status int) Step {
    return fn [status] (mut pipe Pipe) ! {
        pipe.status = status
        pipe.stopped = true
        pipe.stop_kind = .return_only
    }
}

// exit_ stops the outer sequence with the provided status.
// Example: _ := v_scr.exit_(1)
pub fn exit_(status int) Step {
    return fn [status] (mut pipe Pipe) ! {
        pipe.status = status
        pipe.stopped = true
        pipe.stop_kind = .exit_all
    }
}

fn write_stream_to_file(path string, data []u8, append bool) ! {
    if append {
        existing := os.read_file(path) or { '' }
        os.write_file(path, existing + data.bytestr())!
        return
    }
    os.write_file(path, data.bytestr())!
}

fn parse_output_args(args []OutputArg) (string, bool) {
    mut path := ''
    mut append := true
    for arg in args {
        match arg {
            string {
                if path == '' {
                    path = arg
                }
            }
            bool {
                append = arg
            }
        }
    }
    return path, append
}
