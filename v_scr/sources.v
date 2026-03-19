module v_scr

import os

// echo creates a step that writes expanded text to the current output stream.
// Example: _ := v_scr.echo('hello')
pub fn echo(input string) Step {
    return fn [input] (mut pipe Pipe) ! {
        pipe.stdout = expand(input, pipe).bytes()
        pipe.status = 0
    }
}

// echo_args creates a step that joins positional args with spaces.
// Example: _ := v_scr.echo_args()
pub fn echo_args() Step {
    return fn (mut pipe Pipe) ! {
        pipe.stdout = pipe.args.join(' ').bytes()
        pipe.status = 0
    }
}

// cat_file creates a step that reads a file into the current output stream.
// Example: _ := v_scr.cat_file('/tmp/demo.txt')
pub fn cat_file(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        contents := os.read_file(expand(path, pipe))!
        pipe.stdout = contents.bytes()
        pipe.status = 0
    }
}

// cat_stdin creates a step that forwards stdin into stdout.
// Example: _ := v_scr.cat_stdin()
pub fn cat_stdin() Step {
    return fn (mut pipe Pipe) ! {
        pipe.stdout = pipe.stdin.clone()
        pipe.status = 0
    }
}

// from_file is a short alias for cat_file.
// Example: _ := v_scr.from_file('/tmp/demo.txt')
pub fn from_file(path string) Step {
    return cat_file(path)
}

// from_f is a short alias for cat_file.
// Example: _ := v_scr.from_f('/tmp/demo.txt')
pub fn from_f(path string) Step {
    return cat_file(path)
}

// which creates a step that resolves an executable from PATH.
// Example: _ := v_scr.which('v')
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

// list_files creates a step that lists directory entries separated by newlines.
// Example: _ := v_scr.list_files('.')
pub fn list_files(path string) Step {
    return fn [path] (mut pipe Pipe) ! {
        expanded := expand(path, pipe)
        mut files := os.ls(expanded)!
        files.sort()
        pipe.stdout = files.join('\n').bytes()
        pipe.status = 0
    }
}

// ls is a short alias for list_files.
// Example: _ := v_scr.ls('.')
pub fn ls(path string) Step {
    return list_files(path)
}
