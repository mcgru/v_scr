# v_scr Release Checklist

## Pre-release

- [ ] Update version in `v.mod`
- [ ] Update CHANGELOG.md (if exists)
- [ ] Run all tests: `v test tests/`
- [ ] Run `v -check` on all source files
- [ ] Verify examples compile and run
- [ ] Update README.md with new features
- [ ] Update project.md status section

## Testing

- [ ] Test on Linux
- [ ] Test on macOS (if available)
- [ ] Test on Windows (if available)
- [ ] Verify cross-platform compatibility notes in documentation

## Documentation

- [ ] Generate docs: `v doc -o docs/ .`
- [ ] Verify all public functions have documentation comments
- [ ] Check example code in doc comments is up to date
- [ ] Update API cheatsheet in README.md

## Git

- [ ] Commit all changes
- [ ] Create annotated tag: `git tag -a v0.2.0 -m 'Release v0.2.0'`
- [ ] Push tag: `git push origin v0.2.0`

## VPM Publication

- [ ] Verify v.mod is complete
- [ ] Run `v publish` (or manual upload if needed)
- [ ] Verify package appears on VPM

## Post-release

- [ ] Announce release (if applicable)
- [ ] Update any dependent projects
- [ ] Plan next release features

---

## Version History

### v0.2.0 (2026-03-20)

**New Features:**
- File utilities: `cp()`, `mv()`, `ln()`, `readlink()`, `realpath()`
- Enhanced parameter expansion:
  - `${VAR:-default}` - default if unset or empty
  - `${VAR:+value}` - value if set
  - `${#VAR}` - string length
  - `${VAR^^}` - uppercase
  - `${VAR,,}` - lowercase
  - `${VAR:offset}` and `${VAR:offset:len}` - substring

**Improvements:**
- Updated v.mod with repository and homepage links
- Added expand_test.v for parameter expansion tests

**Bug Fixes:**
- None

### v0.1.0 (2026-03-19)

**Initial Release:**
- Core runtime: `Pipe`, `RunResult`, `Pipeline`, `List`
- Process engine via `os.new_process()`
- Shell-like expansion for args, locals, env
- Basic sources, filters, sinks, builtins, logic
- Nested orchestration via `call()` and `invoke()`
- Short and long API aliases
- Runnable examples and tests
