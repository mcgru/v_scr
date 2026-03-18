import os
import v_scr

fn test_file_steps_roundtrip() {
    base := os.join_path(os.vtmp_dir(), 'v_scr_files_test')
    os.rmdir_all(base) or {}

    write_alpha := v_scr.new_pipeline(
        v_scr.echo('alpha'),
        v_scr.write_to_file(os.join_path(base, 'a.txt')),
    )
    append_beta := v_scr.new_pipeline(
        v_scr.echo('\nbeta'),
        v_scr.append_to_file(os.join_path(base, 'a.txt')),
    )
    result := v_scr.new_list(
        v_scr.mkdir(base, 0o755),
        v_scr.run_pipeline(write_alpha),
        v_scr.pipe(
            v_scr.echo('\ngamma'),
            v_scr.append_to_file(os.join_path(base, 'a.txt')),
        ),
        v_scr.run_pipeline(append_beta),
        v_scr.list_files(base),
    ).exec() or {
        os.rmdir_all(base) or {}
        panic(err)
    }

    assert result.trimmed_string() == 'a.txt'
    assert os.read_file(os.join_path(base, 'a.txt')) or { '' } == 'alpha\ngamma\nbeta'

    cleanup := v_scr.new_list(
        v_scr.rm_dir(base),
    ).exec() or { panic(err) }

    assert cleanup.okay()
    assert !os.exists(base)
}

fn test_touch_and_test_filepath_exists() {
    base := os.join_path(os.vtmp_dir(), 'v_scr_touch_test')
    file_path := os.join_path(base, 'touch.txt')
    os.rmdir_all(base) or {}

    result := v_scr.new_list(
        v_scr.mkdir(base, 0o755),
        v_scr.touch(file_path),
        v_scr.test_filepath_exists(file_path),
    ).exec() or {
        os.rmdir_all(base) or {}
        panic(err)
    }

    assert result.okay()
    assert result.trimmed_string() == file_path

    os.rmdir_all(base) or {}
}

fn test_file_aliases() {
    base := os.join_path(os.vtmp_dir(), 'v_scr_aliases_test')
    file_path := os.join_path(base, 'aliases.txt')
    os.rmdir_all(base) or {}

    result := v_scr.new_list(
        v_scr.mkdir(base, 0o755),
        v_scr.pipe(
            v_scr.echo('alpha'),
            v_scr.to_f(file_path),
        ),
        v_scr.pipe(
            v_scr.echo('\nbeta'),
            v_scr.append_f(file_path),
        ),
        v_scr.pipe(
            v_scr.from_f(file_path),
            v_scr.count_lines(),
        ),
    ).exec() or {
        os.rmdir_all(base) or {}
        panic(err)
    }

    assert result.trimmed_string() == '2'

    exists_result := v_scr.new_list(
        v_scr.exists(file_path),
    ).exec() or {
        os.rmdir_all(base) or {}
        panic(err)
    }

    assert exists_result.okay()
    assert exists_result.trimmed_string() == file_path

    listing := v_scr.new_list(
        v_scr.ls(base),
    ).exec() or {
        os.rmdir_all(base) or {}
        panic(err)
    }

    assert listing.trimmed_string() == 'aliases.txt'
    os.rmdir_all(base) or {}
}
