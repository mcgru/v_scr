module v_scr

import os

pub fn to_stdout() Step {
    return fn (mut pipe Pipe) ! {
        print(pipe.stdout.bytestr())
        pipe.status = 0
    }
}

pub fn to_stderr() Step {
    return fn (mut pipe Pipe) ! {
        eprint(pipe.stdout.bytestr())
        pipe.status = 0
    }
}

pub fn write_to_file(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        os.write_file(expand(path, pipe), pipe.stdout.bytestr())!
        pipe.status = 0
    }
}

pub fn append_to_file(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        expanded := expand(path, pipe)
        existing := os.read_file(expanded) or { '' }
        os.write_file(expanded, existing + pipe.stdout.bytestr())!
        pipe.status = 0
    }
}

pub fn return_(status int) Step {
    return fn [status] (mut pipe Pipe) ! {
        pipe.status = status
        pipe.stopped = true
    }
}

pub fn exit_(status int) Step {
    return fn [status] (mut pipe Pipe) ! {
        pipe.status = status
        pipe.stopped = true
    }
}
