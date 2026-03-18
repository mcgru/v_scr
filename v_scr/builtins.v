module v_scr

import os

pub fn mkdir(path string, mode u32) Step {
    return fn [path, mode] (mut pipe Pipe) ! {
        _ = mode
        os.mkdir_all(expand(path, pipe))!
        pipe.status = 0
    }
}

pub fn rm_file(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        expanded := expand(path, pipe)
        if os.exists(expanded) {
            os.rm(expanded)!
        }
        pipe.status = 0
    }
}

pub fn rm_dir(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        expanded := expand(path, pipe)
        if os.exists(expanded) {
            os.rmdir_all(expanded)!
        }
        pipe.status = 0
    }
}

pub fn touch(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        expanded := expand(path, pipe)
        if !os.exists(expanded) {
            os.write_file(expanded, '')!
        }
        pipe.status = 0
    }
}

pub fn chmod(path string, mode u32) Step {
    return fn [path, mode] (mut pipe Pipe) ! {
        os.chmod(expand(path, pipe), int(mode))!
        pipe.status = 0
    }
}

pub fn test_filepath_exists(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        expanded := expand(path, pipe)
        exists := os.exists(expanded)
        pipe.stdout = expanded.bytes()
        pipe.status = if exists { 0 } else { 1 }
    }
}

pub fn test_empty() Step {
    return fn (mut pipe Pipe) ! {
        pipe.status = if pipe.stdin.len == 0 { 0 } else { 1 }
    }
}

pub fn test_not_empty() Step {
    return fn (mut pipe Pipe) ! {
        pipe.status = if pipe.stdin.len > 0 { 0 } else { 1 }
    }
}
