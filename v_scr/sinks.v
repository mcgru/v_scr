module v_scr

import os

// to_stdout creates a step that prints the active stream to stdout.
// Example: _ := v_scr.to_stdout()
pub fn to_stdout() Step {
    return fn (mut pipe Pipe) ! {
        data := active_stream(pipe)
        print(data.bytestr())
        pipe.status = 0
    }
}

// to_stderr creates a step that prints the active stream to stderr.
// Example: _ := v_scr.to_stderr()
pub fn to_stderr() Step {
    return fn (mut pipe Pipe) ! {
        data := active_stream(pipe)
        eprint(data.bytestr())
        pipe.stderr << data
        pipe.stdout = []u8{}
        pipe.status = 0
    }
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
