import v_scr
import os

fn test_pipeline_count_lines() {
    result := v_scr.new_pipeline(
        v_scr.echo('alpha\nbeta\ngamma\n'),
        v_scr.count_lines(),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == '3'
    assert result.okay()
}

fn test_pipeline_grep() {
    step := v_scr.grep('beta') or { panic(err) }
    result := v_scr.new_pipeline(
        v_scr.echo('alpha\nbeta\ngamma\n'),
        step,
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'beta'
    assert result.okay()
}

fn test_pipeline_trim_and_count_words() {
    result := v_scr.new_pipeline(
        v_scr.echo('  one two   three  '),
        v_scr.trim_whitespace(),
        v_scr.count_words(),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == '3'
}

fn test_nested_run_pipeline_keeps_context() {
    inner := v_scr.new_pipeline(
        v_scr.echo('hello \$name'),
    )
    result := v_scr.new_list(
        v_scr.set_local('name', 'world'),
        v_scr.run_pipeline(inner),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'hello world'
}

fn test_expand_args_and_indirect_reference() {
    result := v_scr.new_list(
        v_scr.set_args('one', 'two'),
        v_scr.set_local('ref', 'TARGET'),
        v_scr.set_env_var('TARGET', 'value'),
        v_scr.echo('\$1 \$2 \$# \${!ref}'),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'one two 2 value'
}

fn test_return_stops_current_sequence() {
    result := v_scr.new_list(
        v_scr.echo('first'),
        v_scr.return_(7),
        v_scr.echo('second'),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'first'
    assert result.status_code() == 7
}

fn test_grep_r_and_sort() {
    step := v_scr.grep_r('^a.*') or { panic(err) }
    result := v_scr.new_pipeline(
        v_scr.echo('beta\nalpha\natom\n'),
        step,
        v_scr.sort(),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'alpha\natom'
}

fn test_list_accumulates_stdout() {
    result := v_scr.new_list(
        v_scr.echo('alpha'),
        v_scr.echo('beta'),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'alphabeta'
}

fn test_pipe_helper_matches_run_pipeline_new_pipeline() {
    result := v_scr.new_list(
        v_scr.pipe(
            v_scr.echo('alpha\nbeta\n'),
            v_scr.grep('beta') or { panic(err) },
        ),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'beta'
}

fn test_group_helper_matches_run_list_new_list() {
    result := v_scr.new_list(
        v_scr.group(
            v_scr.echo('left'),
            v_scr.echo('right'),
        ),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'leftright'
}

fn test_sequence_call_uses_positional_args() {
    seq := v_scr.new_list(
        v_scr.echo_args(),
    )
    result := seq.call('alpha', 'beta') or { panic(err) }

    assert result.trimmed_string() == 'alpha beta'
}

fn test_invoke_overrides_args_temporarily() {
    inner := v_scr.new_list(
        v_scr.set_local('inner_seen', '\$1 \$2'),
    )
    result := v_scr.new_list(
        v_scr.set_args('outer'),
        inner.invoke('inner', 'args'),
        v_scr.set_local('saved', '\$1'),
        v_scr.echo('\$saved'),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'outer'
}

fn test_and_or_semantics() {
    fallback := v_scr.new_list(
        v_scr.echo('fallback'),
    )
    success := v_scr.new_list(
        v_scr.echo('success'),
    )
    failing_probe := v_scr.new_pipeline(
        v_scr.echo('x'),
        v_scr.test_empty(),
    )
    result := v_scr.new_list(
        v_scr.run_pipeline(failing_probe),
        v_scr.or_(fallback),
        v_scr.and_(success),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'fallbacksuccess'
    assert result.status_code() == 0
}

fn test_if_and_if_else_semantics() {
    base := os.join_path(os.vtmp_dir(), 'v_scr_if_test')
    file_path := os.join_path(base, 'present.txt')
    os.rmdir_all(base) or {}
    os.mkdir_all(base) or { panic(err) }
    os.write_file(file_path, 'ok') or { panic(err) }

    existing_body := v_scr.new_list(
        v_scr.echo('exists'),
    )
    missing_body := v_scr.new_list(
        v_scr.echo('missing'),
    )

    result := v_scr.new_list(
        v_scr.if_(v_scr.test_filepath_exists(file_path), existing_body),
        v_scr.if_else(v_scr.test_filepath_exists(os.join_path(base, 'absent.txt')), existing_body, missing_body),
    ).exec() or {
        os.rmdir_all(base) or {}
        panic(err)
    }

    os.rmdir_all(base) or {}
    assert result.trimmed_string() == 'existsmissing'
}

fn test_invoke_return_stops_only_inner_sequence() {
    inner := v_scr.new_list(
        v_scr.echo('inner'),
        v_scr.return_(3),
        v_scr.echo('after-return'),
    )
    result := v_scr.new_list(
        inner.invoke(),
        v_scr.echo('outer'),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'innerouter'
    assert result.status_code() == 0
}

fn test_invoke_exit_stops_outer_sequence() {
    inner := v_scr.new_list(
        v_scr.echo('inner'),
        v_scr.exit_(9),
        v_scr.echo('after-exit'),
    )
    result := v_scr.new_list(
        inner.invoke(),
        v_scr.echo('outer'),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'inner'
    assert result.status_code() == 9
}
