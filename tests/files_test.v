import os
import v_scr

fn test_file_steps_roundtrip() {
    base := os.join_path(os.vtmp_dir(), 'v_scr_files_test')
    os.rmdir_all(base) or {}

    result := v_scr.new_list(
        v_scr.mkdir(base, 0o755),
        v_scr.echo('alpha'),
        v_scr.write_to_file(os.join_path(base, 'a.txt')),
        v_scr.echo('\nbeta'),
        v_scr.append_to_file(os.join_path(base, 'a.txt')),
        v_scr.list_files(base),
    ).exec() or {
        os.rmdir_all(base) or {}
        panic(err)
    }

    assert result.trimmed_string() == 'a.txt'
    assert os.read_file(os.join_path(base, 'a.txt')) or { '' } == 'alpha\nbeta'

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
