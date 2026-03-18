module v_scr

pub struct List {
pub:
    steps []Step
}

pub fn new_list(steps ...Step) List {
    return List{
        steps: steps
    }
}

pub fn exec_list(steps ...Step) !RunResult {
    return new_list(...steps).exec()
}

pub fn (list List) exec() !RunResult {
    mut pipe := new_pipe()
    return list.run_into(mut pipe)
}

pub fn (list List) call(args ...string) !RunResult {
    mut pipe := new_pipe()
    pipe.args = args.clone()
    return list.run_into(mut pipe)
}

pub fn (list List) invoke(args ...string) Step {
    values := args.clone()
    return fn [list, values] (mut pipe Pipe) ! {
        result := run_sequence_with_args(mut pipe, list, values)!
        apply_result(mut pipe, result)
    }
}

pub fn (list List) run_into(mut pipe Pipe) !RunResult {
    run_steps(mut pipe, list.steps, .list)!
    return pipe.result()
}
