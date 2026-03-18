import v_scr

fn main() {
    result := v_scr.new_pipeline(
        v_scr.echo('alpha\nbeta\ngamma\n'),
        v_scr.grep('a') or { panic(err) },
        v_scr.count_lines(),
    ).exec() or { panic(err) }

    println(result.trimmed_string())
}
