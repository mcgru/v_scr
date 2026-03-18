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
