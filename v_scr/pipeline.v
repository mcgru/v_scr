module v_scr

pub struct Pipeline {
pub:
    steps []Step
}

pub fn new_pipeline(steps ...Step) Pipeline {
    return Pipeline{
        steps: steps
    }
}

pub fn exec_pipeline(steps ...Step) !RunResult {
    return new_pipeline(...steps).exec()
}

pub fn (pipeline Pipeline) exec() !RunResult {
    mut pipe := new_pipe()
    return pipeline.run_into(mut pipe)
}

pub fn (pipeline Pipeline) call(args ...string) !RunResult {
    mut pipe := new_pipe()
    pipe.args = args.clone()
    return pipeline.run_into(mut pipe)
}

pub fn (pipeline Pipeline) invoke(args ...string) Step {
    values := args.clone()
    return fn [pipeline, values] (mut pipe Pipe) ! {
        result := run_sequence_with_args(mut pipe, pipeline, values)!
        apply_result(mut pipe, result)
    }
}

pub fn (pipeline Pipeline) run_into(mut pipe Pipe) !RunResult {
    run_steps(mut pipe, pipeline.steps, .pipeline)!
    return pipe.result()
}
