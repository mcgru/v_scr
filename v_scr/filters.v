module v_scr

import os
import regex

pub fn trim_whitespace() Step {
    return fn (mut pipe Pipe) ! {
        pipe.stdout = pipe.stdin.bytestr().trim_space().bytes()
        pipe.status = 0
    }
}

pub fn count_lines() Step {
    return fn (mut pipe Pipe) ! {
        text := pipe.stdin.bytestr()
        count := if text == '' { 0 } else { text.split_into_lines().len }
        pipe.stdout = count.str().bytes()
        pipe.status = 0
    }
}

pub fn count_words() Step {
    return fn (mut pipe Pipe) ! {
        count := pipe.stdin.bytestr().fields().len
        pipe.stdout = count.str().bytes()
        pipe.status = 0
    }
}

pub fn grep(pattern string) !Step {
    return fn [pattern] (mut pipe Pipe) ! {
        lines := pipe.stdin.bytestr().split_into_lines()
        mut matched := []string{}
        for line in lines {
            if line.contains(pattern) {
                matched << line
            }
        }
        pipe.stdout = matched.join('\n').bytes()
        pipe.status = if matched.len > 0 { 0 } else { 1 }
    }
}

pub fn grep_v(pattern string) !Step {
    return fn [pattern] (mut pipe Pipe) ! {
        lines := pipe.stdin.bytestr().split_into_lines()
        mut matched := []string{}
        for line in lines {
            if !line.contains(pattern) {
                matched << line
            }
        }
        pipe.stdout = matched.join('\n').bytes()
        pipe.status = if matched.len > 0 { 0 } else { 1 }
    }
}

pub fn grep_r(pattern string) !Step {
    mut re := regex.regex_opt(pattern)!
    return fn [mut re] (mut pipe Pipe) ! {
        lines := pipe.stdin.bytestr().split_into_lines()
        mut matched := []string{}
        for line in lines {
            if re.matches_string(line) {
                matched << line
            }
        }
        pipe.stdout = matched.join('\n').bytes()
        pipe.status = if matched.len > 0 { 0 } else { 1 }
    }
}

pub fn sed(expr string) !Step {
    return fn [expr] (mut pipe Pipe) ! {
        run_process(mut pipe, 'sed', [expr])!
    }
}

pub fn head(n int) Step {
    return fn [n] (mut pipe Pipe) ! {
        lines := pipe.stdin.bytestr().split_into_lines()
        limit := if n < lines.len { n } else { lines.len }
        pipe.stdout = lines[..limit].join('\n').bytes()
        pipe.status = 0
    }
}

pub fn tail(n int) Step {
    return fn [n] (mut pipe Pipe) ! {
        lines := pipe.stdin.bytestr().split_into_lines()
        start := if n < lines.len { lines.len - n } else { 0 }
        pipe.stdout = lines[start..].join('\n').bytes()
        pipe.status = 0
    }
}

pub fn uniq() Step {
    return fn (mut pipe Pipe) ! {
        lines := pipe.stdin.bytestr().split_into_lines()
        mut seen := map[string]bool{}
        mut output := []string{}
        for line in lines {
            if line in seen {
                continue
            }
            seen[line] = true
            output << line
        }
        pipe.stdout = output.join('\n').bytes()
        pipe.status = 0
    }
}

pub fn sort() Step {
    return fn (mut pipe Pipe) ! {
        mut lines := pipe.stdin.bytestr().split_into_lines()
        lines.sort()
        pipe.stdout = lines.join('\n').bytes()
        pipe.status = 0
    }
}

pub fn rsort() Step {
    return fn (mut pipe Pipe) ! {
        mut lines := pipe.stdin.bytestr().split_into_lines()
        lines.sort()
        lines.reverse_in_place()
        pipe.stdout = lines.join('\n').bytes()
        pipe.status = 0
    }
}

pub fn basename() Step {
    return fn (mut pipe Pipe) ! {
        lines := pipe.stdin.bytestr().split_into_lines()
        mut output := []string{}
        for line in lines {
            output << os.base(line)
        }
        pipe.stdout = output.join('\n').bytes()
        pipe.status = 0
    }
}

pub fn dirname() Step {
    return fn (mut pipe Pipe) ! {
        lines := pipe.stdin.bytestr().split_into_lines()
        mut output := []string{}
        for line in lines {
            output << os.dir(line)
        }
        pipe.stdout = output.join('\n').bytes()
        pipe.status = 0
    }
}

pub fn strip_extension() Step {
    return fn (mut pipe Pipe) ! {
        lines := pipe.stdin.bytestr().split_into_lines()
        mut output := []string{}
        for line in lines {
            output << replace_extension(line, '')
        }
        pipe.stdout = output.join('\n').bytes()
        pipe.status = 0
    }
}

pub fn swap_extensions(old_ext string, new_ext string) Step {
    return fn [old_ext, new_ext] (mut pipe Pipe) ! {
        lines := pipe.stdin.bytestr().split_into_lines()
        mut output := []string{}
        for line in lines {
            if line.ends_with(old_ext) {
                output << line[..line.len - old_ext.len] + new_ext
            } else {
                output << replace_extension(line, new_ext)
            }
        }
        pipe.stdout = output.join('\n').bytes()
        pipe.status = 0
    }
}

fn replace_extension(path string, replacement string) string {
    file_name := os.file_name(path)
    idx := file_name.last_index('.') or { -1 }
    if idx <= 0 {
        if replacement == '' {
            return path
        }
        return path + replacement
    }
    base_name := file_name[..idx]
    dir_name := os.dir(path)
    new_name := base_name + replacement
    return if dir_name == '.' { new_name } else { os.join_path(dir_name, new_name) }
}
