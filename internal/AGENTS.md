<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# internal

## Purpose
Private implementation layer for all `rules_bun` Bazel rules. None of these files are intended to be loaded directly by end users. Every public symbol originates here and is re-exported through `//bun:defs.bzl`. This directory also owns `runtime_launcher.js`, the Node.js/Bun-compatible launcher script that sets up the hermetic `PATH` for all executable rules.

## Key Files

| File | Description |
|------|-------------|
| `bun_binary.bzl` | `bun_binary` rule — runfiles-only executable, stages hermetic bun/bunx/node on PATH |
| `bun_build_support.bzl` | Shared helpers for build rules (`bun_bundle`, `bun_compile`, `bun_build`) |
| `bun_bundle.bzl` | `bun_bundle` rule — hermetic `bun build` producing a bundled JS output |
| `bun_command.bzl` | Low-level helper for constructing `bun` CLI invocations |
| `bun_compile.bzl` | `bun_build` and `bun_compile` rules — directory output and standalone executable respectively |
| `bun_dev.bzl` | `bun_dev` rule — long-running watch/hot-reload local development server |
| `bun_install.bzl` | `bun_install_repository` repository rule — runs `bun install --frozen-lockfile` into an external repo |
| `bun_script.bzl` | `bun_script` and `bun_script_test` rules — expose `package.json` scripts as Bazel executables |
| `bun_test.bzl` | `bun_test` rule — hermetic test runner using `bun test` |
| `js_compat.bzl` | `rules_js`-compatible shim: `js_binary`, `js_test`, `js_run_devserver`, `JsInfo` provider |
| `js_library.bzl` | `js_library` and `ts_library` rules — declare JS/TS source filegroups with dependency tracking |
| `js_run_devserver.bzl` | `js_run_devserver` rule — rules_js-compatible devserver launcher |
| `runtime_launcher.bzl` | Starlark helper that stages `runtime_launcher.js` as a runfile for executable rules |
| `runtime_launcher.js` | JS script that constructs hermetic PATH (bun, bunx, node, node_modules/.bin) before execing the target |
| `workspace.bzl` | Helpers for resolving `working_dir` ("workspace" vs "entry_point") |
| `BUILD.bazel` | Exports all .bzl files and declares bzl_library targets for Stardoc |

## For AI Agents

### Working In This Directory
- Changes to rule attribute schemas require regenerating `docs/rules.md` via `bazel build //docs:rules_md`
- `bun_install.bzl` contains both the repository rule (`bun_install_repository`) and the legacy WORKSPACE macro (`bun_install`) — keep them in sync
- `runtime_launcher.js` must remain compatible with both Bun and Node.js as it runs in the exec environment before the Bun toolchain is confirmed
- `js_compat.bzl` is a compatibility subset of `rules_js` — only implement what's documented in README.md
- All hermetic rules (`bun_build`, `bun_bundle`, `bun_compile`, `bun_test`) require `install_mode = "disable"` and must not inherit host PATH

### Testing Requirements
```bash
bazel test //tests/...  # full suite
bazel test //tests/binary_test/...
bazel test //tests/bundle_test/...
bazel test //tests/bun_test_test/...
bazel test //tests/install_test/...
```

### Common Patterns
- All launcher-based rules (`bun_binary`, `bun_script`, `bun_dev`, `js_run_devserver`) share the same `runtime_launcher.js` PATH-staging pattern
- `working_dir` attribute is handled in `workspace.bzl` and shared across `bun_binary`, `bun_dev`
- Package target name sanitization: `@` → `at_`, `/` → `_`, `-` → `_`, prefixed with `npm__`

## Dependencies

### Internal
- All files depend on `bun_command.bzl` for CLI construction
- `runtime_launcher.bzl` + `runtime_launcher.js` are consumed by every executable rule

### External
- `@bazel_skylib//:bzl_library.bzl` — documentation targets only
- `@bun_<platform>//:bun` — resolved at analysis time via `//bun:toolchain_type`

<!-- MANUAL: -->
