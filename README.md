# v_scr

`v_scr` is a shell-like scripting library for V (`v0.5.1+`).

The goal is to make automation code read closer to Bash while keeping V's explicit types, explicit errors, and predictable runtime semantics.

## Status

This repository currently contains a working early implementation:

- core runtime types
- `Pipeline` and `List`
- result helpers
- process execution on top of `os.new_process()`
- variable expansion for args, locals, and env
- a first batch of sources, filters, sinks, builtins, and logic helpers

## Example

```v
import v_scr

result := v_scr.new_pipeline(
    v_scr.echo('alpha\nbeta\ngamma\n'),
    v_scr.grep('a')!,
    v_scr.count_lines(),
).exec()!

assert result.trimmed_string() == '3'
```

## Next steps

- expand file and process integration coverage
- add more shell-like filters and convenience helpers
- refine sequence semantics and release the first `0.1.x` package

See `project.md` for the project plan.
