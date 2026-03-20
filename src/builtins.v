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
    return rm(path)
}

// rm_dir creates a step that removes a directory tree if it exists.
// Example: _ := v_scr.rm_dir('/tmp/demo-dir')
pub fn rm_dir(path string) Step {
    return rmdir('-r', path)
}

// rm removes files and optionally directories with `-r`, while `-f` ignores missing paths and `-q` suppresses stderr.
// Example: _ := v_scr.rm('-f', '/tmp/demo.txt')
pub fn rm(args ...string) Step {
    values := args.clone()
    return fn [values] (mut pipe Pipe) ! {
        config := parse_rm_args(values, pipe)
        if config.paths.len == 0 {
            set_rm_failure(mut pipe, config.quiet, 'rm: missing operand')
            return
        }
        mut status := 0
        for raw_path in config.paths {
            path := expand(raw_path, pipe)
            if !os.exists(path) {
                if config.force {
                    continue
                }
                status = 1
                append_rm_error(mut pipe, config.quiet, 'rm: cannot remove `${path}`: No such file or directory')
                continue
            }
            if os.is_dir(path) {
                if !config.recursive {
                    status = 1
                    append_rm_error(mut pipe, config.quiet, 'rm: cannot remove `${path}`: Is a directory')
                    continue
                }
                os.rmdir_all(path) or {
                    status = 1
                    append_rm_error(mut pipe, config.quiet, 'rm: cannot remove `${path}`: ${err.msg()}')
                }
                continue
            }
            os.rm(path) or {
                status = 1
                append_rm_error(mut pipe, config.quiet, 'rm: cannot remove `${path}`: ${err.msg()}')
            }
        }
        pipe.status = status
    }
}

// rmdir removes directories, using `-r` for recursive deletion, `-f` to ignore missing paths, and `-q` to suppress stderr.
// Example: _ := v_scr.rmdir('-r', '-f', '/tmp/demo-dir')
pub fn rmdir(args ...string) Step {
    values := args.clone()
    return fn [values] (mut pipe Pipe) ! {
        config := parse_rm_args(values, pipe)
        if config.paths.len == 0 {
            set_rm_failure(mut pipe, config.quiet, 'rmdir: missing operand')
            return
        }
        mut status := 0
        for raw_path in config.paths {
            path := expand(raw_path, pipe)
            if !os.exists(path) {
                if config.force {
                    continue
                }
                status = 1
                append_rm_error(mut pipe, config.quiet, 'rmdir: failed to remove `${path}`: No such file or directory')
                continue
            }
            if !os.is_dir(path) {
                status = 1
                append_rm_error(mut pipe, config.quiet, 'rmdir: failed to remove `${path}`: Not a directory')
                continue
            }
            if config.recursive {
                os.rmdir_all(path) or {
                    status = 1
                    append_rm_error(mut pipe, config.quiet, 'rmdir: failed to remove `${path}`: ${err.msg()}')
                }
            } else {
                os.rmdir(path) or {
                    status = 1
                    append_rm_error(mut pipe, config.quiet, 'rmdir: failed to remove `${path}`: ${err.msg()}')
                }
            }
        }
        pipe.status = status
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

// cp_file creates a step that copies a file to a destination.
// Example: _ := v_scr.cp_file('/tmp/src.txt', '/tmp/dst.txt')
pub fn cp_file(src string, dst string) Step {
    return cp(src, dst)
}

// cp creates a step that copies files or directories, supporting `-r` for recursive and `-f` for force.
// Example: _ := v_scr.cp('-r', '/tmp/src', '/tmp/dst')
pub fn cp(args ...string) Step {
    values := args.clone()
    return fn [values] (mut pipe Pipe) ! {
        config := parse_cp_args(values, pipe)
        if config.sources.len == 0 {
            append_cp_error(mut pipe, config.quiet, 'cp: missing file operand')
            pipe.status = 1
            return
        }
        if config.dest == '' {
            append_cp_error(mut pipe, config.quiet, 'cp: missing destination file operand')
            pipe.status = 1
            return
        }
        mut status := 0
        for src in config.sources {
            expanded_src := expand(src, pipe)
            expanded_dst := expand(config.dest, pipe)
            if !os.exists(expanded_src) {
                if config.force {
                    continue
                }
                status = 1
                append_cp_error(mut pipe, config.quiet, 'cp: cannot stat `${expanded_src}`: No such file or directory')
                continue
            }
            if os.is_dir(expanded_src) && !config.recursive {
                status = 1
                append_cp_error(mut pipe, config.quiet, 'cp: -r not specified; omitting directory `${expanded_src}`')
                continue
            }
            if os.is_dir(expanded_src) && config.recursive {
                copy_dir_recursive(expanded_src, expanded_dst, config.force) or {
                    status = 1
                    append_cp_error(mut pipe, config.quiet, 'cp: cannot copy `${expanded_src}`: ${err.msg()}')
                }
            } else {
                os.cp(expanded_src, expanded_dst) or {
                    status = 1
                    append_cp_error(mut pipe, config.quiet, 'cp: cannot copy `${expanded_src}`: ${err.msg()}')
                }
            }
        }
        pipe.status = status
    }
}

// mv_file creates a step that moves a file to a destination.
// Example: _ := v_scr.mv_file('/tmp/src.txt', '/tmp/dst.txt')
pub fn mv_file(src string, dst string) Step {
    return mv(src, dst)
}

// mv creates a step that moves or renames files, supporting `-f` for force.
// Example: _ := v_scr.mv('-f', '/tmp/src.txt', '/tmp/dst.txt')
pub fn mv(args ...string) Step {
    values := args.clone()
    return fn [values] (mut pipe Pipe) ! {
        config := parse_mv_args(values, pipe)
        if config.sources.len == 0 {
            append_mv_error(mut pipe, config.quiet, 'mv: missing file operand')
            pipe.status = 1
            return
        }
        if config.dest == '' {
            append_mv_error(mut pipe, config.quiet, 'mv: missing destination file operand')
            pipe.status = 1
            return
        }
        mut status := 0
        for src in config.sources {
            expanded_src := expand(src, pipe)
            expanded_dst := expand(config.dest, pipe)
            if !os.exists(expanded_src) {
                if config.force {
                    continue
                }
                status = 1
                append_mv_error(mut pipe, config.quiet, 'mv: cannot stat `${expanded_src}`: No such file or directory')
                continue
            }
            os.mv(expanded_src, expanded_dst) or {
                status = 1
                append_mv_error(mut pipe, config.quiet, 'mv: cannot move `${expanded_src}` to `${expanded_dst}`: ${err.msg()}')
            }
        }
        pipe.status = status
    }
}

// ln creates a step that creates links, supporting `-s` for symbolic and `-f` for force.
// Example: _ := v_scr.ln('-s', '/tmp/target.txt', '/tmp/link.txt')
pub fn ln(args ...string) Step {
    values := args.clone()
    return fn [values] (mut pipe Pipe) ! {
        config := parse_ln_args(values, pipe)
        if config.targets.len == 0 {
            append_ln_error(mut pipe, config.quiet, 'ln: missing file operand')
            pipe.status = 1
            return
        }
        mut status := 0
        if config.link_name != '' {
            // ln [-s] target link_name
            if config.targets.len > 1 {
                append_ln_error(mut pipe, config.quiet, 'ln: extra operand `${config.targets[1]}`')
                pipe.status = 1
                return
            }
            expanded_target := expand(config.targets[0], pipe)
            expanded_link := expand(config.link_name, pipe)
            if !os.exists(expanded_target) {
                if config.force {
                    // skip missing target with force
                } else {
                    status = 1
                    append_ln_error(mut pipe, config.quiet, 'ln: failed to create symbolic link `${expanded_link}`: No such file or directory')
                }
            } else {
                create_link(expanded_target, expanded_link, config.symbolic, config.force) or {
                    status = 1
                    append_ln_error(mut pipe, config.quiet, 'ln: failed to create link: ${err.msg()}')
                }
            }
        } else {
            // ln [-s] target... directory
            if config.targets.len < 2 {
                append_ln_error(mut pipe, config.quiet, 'ln: missing destination directory operand')
                pipe.status = 1
                return
            }
            expanded_dir := expand(config.targets[config.targets.len - 1], pipe)
            if !os.is_dir(expanded_dir) {
                status = 1
                append_ln_error(mut pipe, config.quiet, 'ln: `${expanded_dir}` is not a directory')
            } else {
                for i := 0; i < config.targets.len - 1; i++ {
                    expanded_target := expand(config.targets[i], pipe)
                    base_name := os.base(expanded_target)
                    link_path := os.join_path(expanded_dir, base_name)
                    if !os.exists(expanded_target) {
                        if config.force {
                            continue
                        }
                        status = 1
                        append_ln_error(mut pipe, config.quiet, 'ln: failed to create symbolic link in `${expanded_dir}`: No such file or directory')
                        continue
                    }
                    create_link(expanded_target, link_path, config.symbolic, config.force) or {
                        status = 1
                        append_ln_error(mut pipe, config.quiet, 'ln: failed to create link: ${err.msg()}')
                    }
                }
            }
        }
        pipe.status = status
    }
}

// readlink creates a step that prints the value of a symbolic link.
// Example: _ := v_scr.readlink('/tmp/link.txt')
pub fn readlink(args ...string) Step {
    values := args.clone()
    return fn [values] (mut pipe Pipe) ! {
        config := parse_readlink_args(values, pipe)
        if config.paths.len == 0 {
            append_readlink_error(mut pipe, config.quiet, 'readlink: missing operand')
            pipe.status = 1
            return
        }
        mut status := 0
        mut output := []string{}
        for raw_path in config.paths {
            expanded := expand(raw_path, pipe)
            if !os.exists(expanded) {
                if config.force {
                    continue
                }
                status = 1
                append_readlink_error(mut pipe, config.quiet, 'readlink: `${expanded}`: No such file or directory')
                continue
            }
            // Check if it's a symlink by trying to read it
            target := os.readlink(expanded) or {
                if config.force {
                    continue
                }
                status = 1
                append_readlink_error(mut pipe, config.quiet, 'readlink: `${expanded}`: Not a symbolic link')
                continue
            }
            output << target
        }
        if output.len > 0 {
            pipe.stdout = output.join('\n').bytes()
        }
        pipe.status = status
    }
}

// realpath creates a step that prints the absolute canonical path.
// Example: _ := v_scr.realpath('/tmp/../tmp/./file.txt')
pub fn realpath(args ...string) Step {
    values := args.clone()
    return fn [values] (mut pipe Pipe) ! {
        config := parse_readlink_args(values, pipe)
        if config.paths.len == 0 {
            append_readlink_error(mut pipe, config.quiet, 'realpath: missing operand')
            pipe.status = 1
            return
        }
        mut status := 0
        mut output := []string{}
        for raw_path in config.paths {
            expanded := expand(raw_path, pipe)
            if !os.exists(expanded) {
                if config.force {
                    continue
                }
                status = 1
                append_readlink_error(mut pipe, config.quiet, 'realpath: `${expanded}`: No such file or directory')
                continue
            }
            abs_path := os.abs_path(expanded)
            output << abs_path
        }
        if output.len > 0 {
            pipe.stdout = output.join('\n').bytes()
        }
        pipe.status = status
    }
}

struct CpConfig {
mut:
    recursive bool
    force     bool
    quiet     bool
    sources   []string
    dest      string
}

struct MvConfig {
mut:
    force   bool
    quiet   bool
    sources []string
    dest    string
}

struct LnConfig {
mut:
    symbolic bool
    force    bool
    quiet    bool
    targets  []string
    link_name string
}

struct ReadlinkConfig {
mut:
    force  bool
    quiet  bool
    paths  []string
}

fn parse_cp_args(args []string, pipe Pipe) CpConfig {
    mut config := CpConfig{
        sources: []string{}
    }
    mut is_dest := false
    for arg in args {
        expanded := expand(arg, pipe)
        if is_cp_flag(expanded) && !is_dest {
            apply_cp_flag(mut config, expanded)
            continue
        }
        if !is_dest {
            config.sources << expanded
        } else {
            config.dest = expanded
        }
        // After first non-flag argument, next non-flag is dest
        if expanded.len > 0 && expanded[0] != `-` {
            is_dest = true
        }
    }
    return config
}

fn is_cp_flag(arg string) bool {
    return arg.len > 1 && arg[0] == `-`
}

fn apply_cp_flag(mut config CpConfig, arg string) {
    for ch in arg[1..] {
        match ch {
            `r`, `R` { config.recursive = true }
            `f` { config.force = true }
            `q` { config.quiet = true }
            else {}
        }
    }
}

fn copy_dir_recursive(src string, dst string, force bool) ! {
    if !os.is_dir(src) {
        os.cp(src, dst)!
        return
    }
    if !os.exists(dst) {
        os.mkdir_all(dst)!
    }
    entries := os.ls(src)!
    for entry in entries {
        src_path := os.join_path(src, entry)
        dst_path := os.join_path(dst, entry)
        if os.is_dir(src_path) {
            copy_dir_recursive(src_path, dst_path, force)!
        } else {
            if os.exists(dst_path) && !force {
                continue
            }
            os.cp(src_path, dst_path)!
        }
    }
}

fn append_cp_error(mut pipe Pipe, quiet bool, message string) {
    if quiet {
        return
    }
    if pipe.stderr.len > 0 {
        pipe.stderr << '\n'.bytes()
    }
    pipe.stderr << message.bytes()
}

fn parse_mv_args(args []string, pipe Pipe) MvConfig {
    mut config := MvConfig{
        sources: []string{}
    }
    mut is_dest := false
    for arg in args {
        expanded := expand(arg, pipe)
        if is_mv_flag(expanded) && !is_dest {
            apply_mv_flag(mut config, expanded)
            continue
        }
        if !is_dest {
            config.sources << expanded
        } else {
            config.dest = expanded
        }
        if expanded.len > 0 && expanded[0] != `-` {
            is_dest = true
        }
    }
    return config
}

fn is_mv_flag(arg string) bool {
    return arg.len > 1 && arg[0] == `-`
}

fn apply_mv_flag(mut config MvConfig, arg string) {
    for ch in arg[1..] {
        match ch {
            `f` { config.force = true }
            `q` { config.quiet = true }
            else {}
        }
    }
}

fn append_mv_error(mut pipe Pipe, quiet bool, message string) {
    if quiet {
        return
    }
    if pipe.stderr.len > 0 {
        pipe.stderr << '\n'.bytes()
    }
    pipe.stderr << message.bytes()
}

fn parse_ln_args(args []string, pipe Pipe) LnConfig {
    mut config := LnConfig{
        targets: []string{}
    }
    for arg in args {
        expanded := expand(arg, pipe)
        if is_ln_flag(expanded) {
            apply_ln_flag(mut config, expanded)
            continue
        }
        config.targets << expanded
    }
    if config.targets.len > 1 {
        config.link_name = config.targets[config.targets.len - 1]
        config.targets = config.targets[..config.targets.len - 1]
    }
    return config
}

fn is_ln_flag(arg string) bool {
    return arg.len > 1 && arg[0] == `-`
}

fn apply_ln_flag(mut config LnConfig, arg string) {
    for ch in arg[1..] {
        match ch {
            `s` { config.symbolic = true }
            `f` { config.force = true }
            `q` { config.quiet = true }
            else {}
        }
    }
}

fn create_link(target string, link_path string, symbolic bool, force bool) ! {
    if os.exists(link_path) && !force {
        return error('file exists')
    }
    if force && os.exists(link_path) {
        os.rm(link_path) or {}
    }
    if symbolic {
        os.symlink(target, link_path)!
    } else {
        os.link(target, link_path)!
    }
}

fn append_ln_error(mut pipe Pipe, quiet bool, message string) {
    if quiet {
        return
    }
    if pipe.stderr.len > 0 {
        pipe.stderr << '\n'.bytes()
    }
    pipe.stderr << message.bytes()
}

fn parse_readlink_args(args []string, pipe Pipe) ReadlinkConfig {
    mut config := ReadlinkConfig{
        paths: []string{}
    }
    for arg in args {
        expanded := expand(arg, pipe)
        if is_readlink_flag(expanded) {
            apply_readlink_flag(mut config, expanded)
            continue
        }
        config.paths << expanded
    }
    return config
}

fn is_readlink_flag(arg string) bool {
    return arg.len > 1 && arg[0] == `-`
}

fn apply_readlink_flag(mut config ReadlinkConfig, arg string) {
    for ch in arg[1..] {
        match ch {
            `f` { config.force = true }
            `q` { config.quiet = true }
            else {}
        }
    }
}

fn append_readlink_error(mut pipe Pipe, quiet bool, message string) {
    if quiet {
        return
    }
    if pipe.stderr.len > 0 {
        pipe.stderr << '\n'.bytes()
    }
    pipe.stderr << message.bytes()
}

struct RmConfig {
mut:
    recursive bool
    force     bool
    quiet     bool
    paths     []string
}

fn parse_rm_args(args []string, pipe Pipe) RmConfig {
    mut config := RmConfig{
        paths: []string{}
    }
    for arg in args {
        expanded := expand(arg, pipe)
        if is_rm_flag(expanded) {
            apply_rm_flag(mut config, expanded)
            continue
        }
        config.paths << expanded
    }
    return config
}

fn is_rm_flag(arg string) bool {
    return arg.len > 1 && arg[0] == `-`
}

fn apply_rm_flag(mut config RmConfig, arg string) {
    for ch in arg[1..] {
        match ch {
            `r` { config.recursive = true }
            `f` { config.force = true }
            `q` { config.quiet = true }
            else {}
        }
    }
}

fn set_rm_failure(mut pipe Pipe, quiet bool, message string) {
    append_rm_error(mut pipe, quiet, message)
    pipe.status = 1
}

fn append_rm_error(mut pipe Pipe, quiet bool, message string) {
    if quiet {
        return
    }
    if pipe.stderr.len > 0 {
        pipe.stderr << '\n'.bytes()
    }
    pipe.stderr << message.bytes()
}
