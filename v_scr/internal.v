module v_scr

enum SequenceMode {
    pipeline
    list
}

fn run_steps(mut pipe Pipe, steps []Step, mode SequenceMode) ! {
    for index, step in steps {
        if pipe.stopped {
            break
        }
        if mode == .pipeline && index > 0 {
            pipe.stdin = pipe.stdout.clone()
            pipe.stdout = []u8{}
        }
        step(mut pipe)!
        if pipe.stopped {
            break
        }
    }
}

fn run_sequence_with_args(mut pipe Pipe, sequence Sequence, args []string) !RunResult {
    expanded_args := expand_all(args, pipe)
    saved_args := pipe.args.clone()
    defer {
        pipe.args = saved_args
    }
    pipe.args = expanded_args
    return sequence.run_into(mut pipe)
}
