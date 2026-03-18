module v_scr

pub fn pipe(steps ...Step) Step {
    return run_pipeline(new_pipeline(...steps))
}

pub fn group(steps ...Step) Step {
    return run_list(new_list(...steps))
}

pub fn run_pipeline(pipeline Pipeline) Step {
    return fn [pipeline] (mut pipe Pipe) ! {
        result := pipeline.run_into(mut pipe)!
        apply_result(mut pipe, result)
    }
}

pub fn run_list(list List) Step {
    return fn [list] (mut pipe Pipe) ! {
        result := list.run_into(mut pipe)!
        apply_result(mut pipe, result)
    }
}

pub fn and_(sequence Sequence) Step {
    return fn [sequence] (mut pipe Pipe) ! {
        if pipe.status != 0 {
            return
        }
        result := sequence.run_into(mut pipe)!
        apply_result(mut pipe, result)
    }
}

pub fn or_(sequence Sequence) Step {
    return fn [sequence] (mut pipe Pipe) ! {
        if pipe.status == 0 {
            return
        }
        result := sequence.run_into(mut pipe)!
        apply_result(mut pipe, result)
    }
}

pub fn if_(expr Step, body Sequence) Step {
    return fn [expr, body] (mut pipe Pipe) ! {
        mut probe := pipe.snapshot()
        expr(mut probe)!
        if probe.status == 0 {
            result := body.run_into(mut pipe)!
            apply_result(mut pipe, result)
            return
        }
        pipe.status = probe.status
    }
}

pub fn if_else(expr Step, body Sequence, else_body Sequence) Step {
    return fn [expr, body, else_body] (mut pipe Pipe) ! {
        mut probe := pipe.snapshot()
        expr(mut probe)!
        result := if probe.status == 0 { body.run_into(mut pipe)! } else { else_body.run_into(mut pipe)! }
        apply_result(mut pipe, result)
    }
}
