import v_scr

fn test_exec_cat_stdin_roundtrip() {
    $if windows {
        return
    }
    result := v_scr.new_pipeline(
        v_scr.echo('hello from stdin'),
        v_scr.exec('cat'),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'hello from stdin'
    assert result.status_code() == 0
}

fn test_sh_uses_env() {
    $if windows {
        return
    }
    result := v_scr.new_list(
        v_scr.set_env_var('VSCR_DEMO', 'works'),
        v_scr.sh('printf %s "\$VSCR_DEMO"'),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'works'
}

fn test_which_returns_path() {
    result := v_scr.new_list(
        v_scr.which('v'),
    ).exec() or { panic(err) }

    assert result.okay()
    assert result.trimmed_string() != ''
}

fn test_set_cwd_affects_process() {
    $if windows {
        return
    }
    target := '/tmp'
    result := v_scr.new_list(
        v_scr.cd(target),
        v_scr.sh('pwd'),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == target
}

fn test_sed_filter() {
    $if windows {
        return
    }
    step := v_scr.sed('s/b/B/g') or { panic(err) }
    result := v_scr.new_pipeline(
        v_scr.echo('abc'),
        step,
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'aBc'
}

fn test_non_zero_exit_code_and_stderr_capture() {
    $if windows {
        return
    }
    result := v_scr.new_list(
        v_scr.sh('printf "boom\n" 1>&2; exit 7'),
    ).exec() or { panic(err) }

    assert result.status_code() == 7
    assert result.stderr_string().trim_space() == 'boom'
}

fn test_list_accumulates_stderr() {
    $if windows {
        return
    }
    result := v_scr.new_list(
        v_scr.sh('printf "first\n" 1>&2'),
        v_scr.sh('printf "second\n" 1>&2'),
    ).exec() or { panic(err) }

    assert result.stderr_strings().len == 2
    assert result.stderr_strings()[0] == 'first'
    assert result.stderr_strings()[1] == 'second'
}

fn test_pipeline_keeps_stdout_and_accumulates_stderr() {
    $if windows {
        return
    }
    result := v_scr.new_pipeline(
        v_scr.sh('printf "alpha\nbeta\n"; printf "warn\n" 1>&2'),
        v_scr.count_lines(),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == '2'
    assert result.stderr_string().trim_space() == 'warn'
}

fn test_invoke_preserves_outer_env_and_cwd_context() {
    $if windows {
        return
    }
    inner := v_scr.new_list(
        v_scr.sh('printf "%s|" "\$VSCR_CTX"; pwd'),
    )
    result := v_scr.new_list(
        v_scr.env('VSCR_CTX', 'outer'),
        v_scr.cd('/tmp'),
        inner.invoke('ignored'),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'outer|/tmp'
}
