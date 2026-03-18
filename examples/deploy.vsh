import v_scr

fn main() {
    result := v_scr.new_list(
        v_scr.set_env_var('APP_NAME', 'demo-app'),
        v_scr.sh('printf "deploying %s\n" "\$APP_NAME"'),
    ).exec() or { panic(err) }

    print(result.string())
}
