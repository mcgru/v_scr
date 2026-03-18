module v_scr

import os

pub fn to_stdout() Step {
    return fn (mut pipe Pipe) ! {
        data := active_stream(pipe)
        print(data.bytestr())
        pipe.status = 0
    }
}

pub fn to_stderr() Step {
    return fn (mut pipe Pipe) ! {
        data := active_stream(pipe)
        eprint(data.bytestr())
        pipe.stderr << data
        pipe.stdout = []u8{}
        pipe.status = 0
    }
}

pub fn write_to_file(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        os.write_file(expand(path, pipe), active_stream(pipe).bytestr())!
        pipe.status = 0
    }
}

pub fn append_to_file(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        expanded := expand(path, pipe)
        existing := os.read_file(expanded) or { '' }
        os.write_file(expanded, existing + active_stream(pipe).bytestr())!
        pipe.status = 0
    }
}

pub fn return_(status int) Step {
    return fn [status] (mut pipe Pipe) ! {
        pipe.status = status
        pipe.stopped = true
        pipe.stop_kind = .return_only
    }
}

pub fn exit_(status int) Step {
    return fn [status] (mut pipe Pipe) ! {
        pipe.status = status
        pipe.stopped = true
        pipe.stop_kind = .exit_all
    }
}
