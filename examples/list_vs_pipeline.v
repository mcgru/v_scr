import os
import v_scr

fn main() {
    target := os.join_path(os.vtmp_dir(), 'v_scr-list-vs-pipeline.txt')

    write_release_note := v_scr.new_pipeline(
        v_scr.echo('release: demo-app\n'),
        v_scr.write_to_file(target),
    )

    orchestrated := v_scr.new_list(
        v_scr.run_pipeline(write_release_note),
        v_scr.echo('written to ${target}\n'),
    ).exec() or { panic(err) }

    print(orchestrated.string())
}
