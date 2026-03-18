import os
import v_scr

fn main() {
    target := os.join_path(os.vtmp_dir(), 'v_scr-list-vs-pipeline.txt')

    orchestrated := v_scr.new_list(
        v_scr.pipe(
            v_scr.echo('release: demo-app\n'),
            v_scr.to_f(target),
        ),
        v_scr.echo('written to ${target}\n'),
    ).exec() or { panic(err) }

    print(orchestrated.string())
}
