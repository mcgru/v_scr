module v_scr

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
    stopped bool
}

pub fn new_pipe() Pipe {
    return Pipe{
        status: 0
        env: map[string]string{}
        args: []string{}
        locals: map[string]string{}
        stopped: false
    }
}

pub fn (p Pipe) result() RunResult {
    return RunResult{
        stdout: p.stdout.clone()
        stderr: p.stderr.clone()
        status: p.status
    }
}

fn (p Pipe) snapshot() Pipe {
    return Pipe{
        stdin: p.stdin.clone()
        stdout: p.stdout.clone()
        stderr: p.stderr.clone()
        status: p.status
        cwd: p.cwd
        env: p.env.clone()
        args: p.args.clone()
        locals: p.locals.clone()
        trace: p.trace
        stopped: p.stopped
    }
}

fn apply_result(mut pipe Pipe, result RunResult) {
    pipe.stdout = result.stdout.clone()
    pipe.stderr = result.stderr.clone()
    pipe.status = result.status
}
