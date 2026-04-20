<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# tests/js_compat_test

## Purpose
Tests for the `@rules_bun//js:defs.bzl` compatibility layer. Validates that `js_binary`, `js_library`, `js_run_devserver`, and the workspace shape produced by `npm_link_all_packages` work as expected.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Test target declarations |
| `main.ts` | Entry point for `js_binary` smoke test |
| `app.test.ts` | Bun test suite for js_compat functionality |
| `helper.ts` | Shared test helpers |
| `payload.txt` | Data file runfile fixture |
| `run_binary.sh` | Invokes `js_binary` target and asserts output |
| `run_devserver.sh` | Invokes `js_run_devserver` and validates startup |
| `verify_workspace_shape.sh` | Validates `npm_link_all_packages` workspace shape |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `app/` | Minimal app fixture with `package.json` for workspace shape tests |

## For AI Agents

### Working In This Directory
- Tests here validate `//internal:js_compat.bzl` and `//js:defs.bzl`
- When adding new symbols to the compat layer, add corresponding tests here

### Testing Requirements
```bash
bazel test //tests/js_compat_test/...
```

<!-- MANUAL: -->
