module v_scr

pub type Step = fn (mut Pipe) !

pub interface Sequence {
    exec() !RunResult
    run_into(mut pipe Pipe) !RunResult
}
