import v_scr

fn main() {
    result := v_scr.new_pipeline(
        v_scr.echo(' one \n two \n three \n'),
        v_scr.trim_whitespace(),
        v_scr.count_lines(),
    ).exec() or { panic(err) }

    println('count=${result.trimmed_string()}')
}
