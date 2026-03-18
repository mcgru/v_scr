module v_scr

import strconv

pub struct RunResult {
pub:
    stdout []u8
    stderr []u8
    status int
}

pub fn (result RunResult) bytes() []u8 {
    return result.stdout.clone()
}

pub fn (result RunResult) string() string {
    return result.stdout.bytestr()
}

pub fn (result RunResult) stderr_string() string {
    return result.stderr.bytestr()
}

pub fn (result RunResult) stderr_bytes() []u8 {
    return result.stderr.clone()
}

pub fn (result RunResult) trimmed_string() string {
    return result.string().trim_space()
}

pub fn (result RunResult) strings() []string {
    text := result.trimmed_string()
    if text == '' {
        return []string{}
    }
    return text.split_into_lines()
}

pub fn (result RunResult) stderr_strings() []string {
    text := result.stderr_string().trim_space()
    if text == '' {
        return []string{}
    }
    return text.split_into_lines()
}

pub fn (result RunResult) parse_int() !int {
    return strconv.atoi(result.trimmed_string())
}

pub fn (result RunResult) okay() bool {
    return result.status == 0
}

pub fn (result RunResult) status_code() int {
    return result.status
}
