<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# tests/library_test

## Purpose
Tests for `js_library` and `ts_library` rules. Validates that source files and transitive dependencies are correctly propagated via `JsInfo`, and that bundling a library produces the expected output.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Test target declarations including `js_library`, `ts_library`, and `bun_bundle` targets |
| `app.ts` | TypeScript application that imports from a library |
| `app.test.ts` | Bun test suite for library behavior |
| `helper.ts` | Shared helper module — declared as a `ts_library` dependency |
| `verify_bundle.sh` | Validates that bundling a `ts_library` dependency produces correct output |

## For AI Agents

### Working In This Directory
- Tests here validate `//internal:js_library.bzl`
- If modifying `JsInfo` provider fields, run all tests that consume it (binary, compat, library)

### Testing Requirements
```bash
bazel test //tests/library_test/...
```

<!-- MANUAL: -->
