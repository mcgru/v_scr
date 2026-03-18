module v_scr

import os

pub fn echo(input string) Step {
    return fn [input] (mut pipe Pipe) ! {
        pipe.stdout = expand(input, pipe).bytes()
        pipe.status = 0
    }
}

pub fn echo_args() Step {
    return fn (mut pipe Pipe) ! {
        pipe.stdout = pipe.args.join(' ').bytes()
        pipe.status = 0
    }
}

pub fn cat_file(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        contents := os.read_file(expand(path, pipe))!
        pipe.stdout = contents.bytes()
        pipe.status = 0
    }
}

pub fn cat_stdin() Step {
    return fn (mut pipe Pipe) ! {
        pipe.stdout = pipe.stdin.clone()
        pipe.status = 0
    }
}

pub fn from_file(path string) Step {
    return cat_file(path)
}

pub fn from_f(path string) Step {
    return cat_file(path)
}

pub fn which(cmd string) Step {
    return fn [cmd] (mut pipe Pipe) ! {
        expanded := expand(cmd, pipe)
        resolved := os.find_abs_path_of_executable(expanded) or {
            pipe.stdout = []u8{}
            pipe.stderr = 'command not found: ${expanded}'.bytes()
            pipe.status = 1
            return
        }
        pipe.stdout = resolved.bytes()
        pipe.status = 0
    }
}

pub fn list_files(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        expanded := expand(path, pipe)
        mut files := os.ls(expanded)!
        files.sort()
        pipe.stdout = files.join('\n').bytes()
        pipe.status = 0
    }
}

pub fn ls(path string) Step {
    return list_files(path)
}
