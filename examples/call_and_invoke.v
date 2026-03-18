import v_scr

fn main() {
    greeter := v_scr.new_list(
        v_scr.local_('name', '\$1'),
        v_scr.echo('hello, \$name'),
    )

    direct := greeter.call('direct') or { panic(err) }
    nested := v_scr.new_list(
        v_scr.echo('before|'),
        greeter.invoke('nested'),
        v_scr.echo('|after'),
    ).exec() or { panic(err) }

    println(direct.trimmed_string())
    println(nested.trimmed_string())
}
