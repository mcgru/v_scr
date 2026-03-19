module v_scr

import os

// mkdir creates a step that ensures a directory exists.
// Example: _ := v_scr.mkdir('/tmp/demo', 0o755)
pub fn mkdir(path string, mode u32) Step {
    return fn [path, mode] (mut pipe Pipe) ! {
        _ = mode
        os.mkdir_all(expand(path, pipe))!
        pipe.status = 0
    }
}

// rm_file creates a step that removes a file if it exists.
// Example: _ := v_scr.rm_file('/tmp/demo.txt')
pub fn rm_file(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        expanded := expand(path, pipe)
        if os.exists(expanded) {
            os.rm(expanded)!
        }
        pipe.status = 0
    }
}

// rm_dir creates a step that removes a directory tree if it exists.
// Example: _ := v_scr.rm_dir('/tmp/demo-dir')
pub fn rm_dir(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        expanded := expand(path, pipe)
        if os.exists(expanded) {
            os.rmdir_all(expanded)!
        }
        pipe.status = 0
    }
}

// touch creates a step that creates an empty file when it does not exist.
// Example: _ := v_scr.touch('/tmp/demo.txt')
pub fn touch(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        expanded := expand(path, pipe)
        if !os.exists(expanded) {
            os.write_file(expanded, '')!
        }
        pipe.status = 0
    }
}

// chmod creates a step that changes file permissions.
// Example: _ := v_scr.chmod('/tmp/demo.txt', 0o644)
pub fn chmod(path string, mode u32) Step {
    return fn [path, mode] (mut pipe Pipe) ! {
        os.chmod(expand(path, pipe), int(mode))!
        pipe.status = 0
    }
}

// test_filepath_exists creates a step that succeeds when the path exists.
// Example: _ := v_scr.test_filepath_exists('/tmp/demo.txt')
pub fn test_filepath_exists(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        expanded := expand(path, pipe)
        exists := os.exists(expanded)
        pipe.stdout = expanded.bytes()
        pipe.status = if exists { 0 } else { 1 }
    }
}

// exists is a short alias for test_filepath_exists.
// Example: _ := v_scr.exists('/tmp/demo.txt')
pub fn exists(path string) Step {
    return test_filepath_exists(path)
}

// test_empty creates a step that succeeds when the active stream is empty.
// Example: _ := v_scr.test_empty()
pub fn test_empty() Step {
    return fn (mut pipe Pipe) ! {
        pipe.status = if active_stream(pipe).len == 0 { 0 } else { 1 }
    }
}

// empty is a short alias for test_empty.
// Example: _ := v_scr.empty()
pub fn empty() Step {
    return test_empty()
}

// test_not_empty creates a step that succeeds when the active stream is not empty.
// Example: _ := v_scr.test_not_empty()
pub fn test_not_empty() Step {
    return fn (mut pipe Pipe) ! {
        pipe.status = if active_stream(pipe).len > 0 { 0 } else { 1 }
    }
}

// non_empty is a short alias for test_not_empty.
// Example: _ := v_scr.non_empty()
pub fn non_empty() Step {
    return test_not_empty()
}
